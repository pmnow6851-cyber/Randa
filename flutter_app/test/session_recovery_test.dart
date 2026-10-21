import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:randa_mkcool_aim_sync/core/session_token_store.dart';
import 'package:randa_mkcool_aim_sync/main.dart';

const _accessKey = 'randa_access_token_v1';
const _refreshKey = 'randa_refresh_token_v1';
const _user = '{"id":"fixture-user","email":"fixture@example.com"}';

class _MemoryTokens implements SessionTokenStore {
  _MemoryTokens({String? access = 'fixture-access', String? refresh = 'fixture-refresh'})
      : values = {
          if (access != null) _accessKey: access,
          if (refresh != null) _refreshKey: refresh,
        };
  final Map<String, String> values;
  bool failRead = false;
  int deletes = 0;
  @override
  Future<String?> read({required String key}) async {
    if (failRead) throw StateError('fixture storage failure');
    return values[key];
  }
  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
  @override
  Future<void> delete({required String key}) async {
    deletes++;
    values.remove(key);
  }
}

MockClient _client(FutureOr<http.Response> Function(http.Request) handle) =>
    MockClient((request) async {
      if (request.url.path.endsWith('/system-health')) return http.Response('{"ok":true}', 200);
      if (request.url.path == '/rest/v1/access_entitlements') return http.Response('[]', 200);
      return handle(request);
    });

Future<void> _mount(WidgetTester tester, _MemoryTokens tokens, http.Client client) async {
  addTearDown(client.close);
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(useMaterial3: true),
    home: AimSyncHome(tokenStore: tokens, client: client),
  ));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void _expectLocked() {
  expect(find.text('PAID ACCESS ACTIVE'), findsNothing);
  expect(find.text('ONE-TAP COPY CONFIG'), findsNothing);
  expect(find.text('VIEW FULL AIM SYNC'), findsNothing);
}

void main() {
  testWidgets('storage errors finish startup and expose a safe retry', (tester) async {
    final tokens = _MemoryTokens()..failRead = true;
    await _mount(tester, tokens, _client((_) => http.Response(_user, 200)));
    expect(find.text('RETRY CONNECTION'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tokens.deletes, 0);
    _expectLocked();
  });
  testWidgets('server failures keep saved tokens and hide paid output', (tester) async {
    final tokens = _MemoryTokens();
    await _mount(tester, tokens, _client((_) => http.Response('{}', 503)));
    expect(tokens.values[_accessKey], 'fixture-access');
    expect(tokens.values[_refreshKey], 'fixture-refresh');
    expect(tokens.deletes, 0);
    expect(find.text('RETRY CONNECTION'), findsOneWidget);
    _expectLocked();
  });
  testWidgets('failed refresh preserves recovery after an expired token', (tester) async {
    final tokens = _MemoryTokens();
    await _mount(tester, tokens, _client((request) => http.Response('{}',
        request.url.path == '/auth/v1/user' ? 401 : 503)));
    expect(tokens.values.length, 2);
    expect(tokens.deletes, 0);
    expect(find.text('RETRY CONNECTION'), findsOneWidget);
    _expectLocked();
  });
  testWidgets('refresh-only storage restores identity without paid access', (tester) async {
    final tokens = _MemoryTokens(access: null);
    var refreshes = 0;
    await _mount(tester, tokens, _client((request) {
      if (request.url.path == '/auth/v1/token') {
        refreshes++;
        expect(jsonDecode(request.body)['refresh_token'], 'fixture-refresh');
        return http.Response('{"access_token":"next-access","refresh_token":"next-refresh"}', 200);
      }
      return http.Response(_user, 200);
    }));
    expect(refreshes, 1);
    expect(tokens.values[_accessKey], 'next-access');
    expect(find.text('SIGNED IN'), findsOneWidget);
    _expectLocked();
  });
  testWidgets('definitively rejected refresh clears both saved tokens', (tester) async {
    final tokens = _MemoryTokens();
    await _mount(tester, tokens, _client((request) => http.Response('{}',
        request.url.path == '/auth/v1/user' ? 401 : 400)));
    expect(tokens.values, isEmpty);
    expect(tokens.deletes, 2);
    expect(find.text('SIGNED IN'), findsNothing);
    _expectLocked();
  });
  testWidgets('malformed user responses keep recovery locked', (tester) async {
    final tokens = _MemoryTokens();
    await _mount(tester, tokens, _client((_) => http.Response('{"id":17}', 200)));
    expect(tokens.values.length, 2);
    expect(tokens.deletes, 0);
    expect(find.text('RETRY CONNECTION'), findsOneWidget);
    _expectLocked();
  });
  testWidgets('malformed refreshed tokens cannot overwrite a saved pair', (tester) async {
    final tokens = _MemoryTokens();
    await _mount(tester, tokens, _client((request) => request.url.path == '/auth/v1/user'
        ? http.Response('{}', 401)
        : http.Response('{"access_token":17,"refresh_token":"next-refresh"}', 200)));
    expect(tokens.values[_accessKey], 'fixture-access');
    expect(tokens.values[_refreshKey], 'fixture-refresh');
    expect(tokens.deletes, 0);
    _expectLocked();
  });
  testWidgets('retry restores identity after a temporary failure', (tester) async {
    final tokens = _MemoryTokens();
    var available = false;
    await _mount(tester, tokens, _client((_) => available
        ? http.Response(_user, 200) : http.Response('{}', 503)));
    available = true;
    await tester.tap(find.text('RETRY CONNECTION'));
    await tester.pumpAndSettle();
    expect(find.text('SIGNED IN'), findsOneWidget);
    expect(find.text('RETRY CONNECTION'), findsNothing);
    expect(tokens.deletes, 0);
    _expectLocked();
  });
  testWidgets('a stalled health request cannot leave startup spinning', (tester) async {
    final tokens = _MemoryTokens(access: null, refresh: null);
    final pending = Completer<http.Response>();
    final client = MockClient((_) => pending.future);
    addTearDown(client.close);
    await tester.pumpWidget(MaterialApp(home: AimSyncHome(tokenStore: tokens, client: client)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'SIGN IN')).onPressed, isNotNull);
    _expectLocked();
    pending.complete(http.Response('{"ok":true}', 200));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets('a late refresh cannot restore tokens after sign-out', (tester) async {
    final tokens = _MemoryTokens();
    final pending = Completer<http.Response>();
    var rejectEntitlement = false;
    var refreshes = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/system-health')) return http.Response('{"ok":true}', 200);
      if (request.url.path == '/auth/v1/user') return http.Response(_user, 200);
      if (request.url.path == '/rest/v1/access_entitlements') return http.Response('[]', rejectEntitlement ? 401 : 200);
      if (request.url.path == '/auth/v1/token') {
        refreshes++;
        return pending.future;
      }
      return http.Response('{}', 200);
    });
    await _mount(tester, tokens, client);
    rejectEntitlement = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(refreshes, 1);
    await tester.tap(find.text('SIGN OUT'));
    await tester.pumpAndSettle();
    pending.complete(http.Response('{"access_token":"late-access","refresh_token":"late-refresh"}', 200));
    await tester.pumpAndSettle();
    expect(tokens.values, isEmpty);
    expect(find.text('SIGNED IN'), findsNothing);
    _expectLocked();
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects an active pro grant when an older record is revoked',
      (tester) async {
    final tokens = _MemoryTokens();
    var queryWasScoped = false;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/system-health')) {
        return http.Response('{"ok":true}', 200);
      }
      if (request.url.path == '/auth/v1/user') {
        return http.Response(_user, 200);
      }
      if (request.url.path == '/rest/v1/access_entitlements') {
        final filters = request.url.queryParameters;
        queryWasScoped = filters['user_id'] == 'eq.fixture-user' &&
            filters['tier'] == 'eq.pro' &&
            filters['status'] == 'eq.active';
        const grants = [
          {'tier': 'pro', 'status': 'revoked'},
          {'tier': 'pro', 'status': 'active'},
        ];
        final matches = grants
            .where((grant) =>
                (filters['tier'] == null ||
                    filters['tier'] == 'eq.${grant['tier']}') &&
                (filters['status'] == null ||
                    filters['status'] == 'eq.${grant['status']}'))
            .take(1)
            .toList();
        return http.Response(jsonEncode(matches), 200);
      }
      if (request.url.path.endsWith('/calculate-aim-sync')) {
        return http.Response('{"error":"fixture"}', 503);
      }
      return http.Response('{}', 404);
    });

    await _mount(tester, tokens, client);
    expect(queryWasScoped, isTrue);
    expect(find.text('PAID ACCESS ACTIVE'), findsOneWidget);
    expect(tokens.deletes, 0);
  });

}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randa_mkcool_aim_sync/screens/sync_result_screen.dart';

const _scopes = <String>[
  'Standard',
  'Red Dot / Holo',
  'ADS',
  'Tactical Scope',
  '3x',
  '4x',
  '6x',
  '8x',
  'Sniper',
];

List<Map<String, Object>> _section() => [
      for (final scope in _scopes) {'label': scope, 'value': 0},
      {'label': 'Vertical Turning Sensitivity', 'value': 0},
    ];

Map<String, Object> _completeMode() => {
      'camera': _section(),
      'firing': _section(),
      'gyroscope': _section(),
      'gyroscope_firing': _section(),
    };

Map<String, dynamic> _completeResult() => {
      'sync_score': 0,
      'full_config': {
        'multiplayer': _completeMode(),
        'battle_royale': _completeMode(),
      },
    };

void main() {
  testWidgets('copy rechecks paid access and closes a revoked result', (tester) async {
    var checks = 0;
    var clipboardWrites = 0;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clipboardWrites++;
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => SyncResultScreen(
                  result: _completeResult(),
                  baseSensitivity: 10,
                  inputFov: 51,
                  selectedRotation: 'fixed',
                  requestedMode: 'mp',
                  verifyPaidAccess: () async {
                    checks++;
                    return false;
                  },
                ),
              ),
            ),
            child: const Text('OPEN RESULT'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('OPEN RESULT'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ONE-TAP COPY CONFIG'));
    await tester.pumpAndSettle();

    expect(checks, 1);
    expect(clipboardWrites, 0);
    expect(find.text('SYNC COMPLETE'), findsNothing);
    expect(find.text('OPEN RESULT'), findsOneWidget);
  });

  testWidgets('a freshly verified full result copies the requested modes', (tester) async {
    var clipboardWrites = 0;
    String? copiedText;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardWrites++;
        copiedText = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(MaterialApp(
      home: SyncResultScreen(
        result: _completeResult(),
        baseSensitivity: 10,
        inputFov: 51,
        selectedRotation: 'fixed',
        requestedMode: 'both',
        verifyPaidAccess: () async => true,
      ),
    ));
    await tester.tap(find.text('ONE-TAP COPY CONFIG'));
    await tester.pump();

    expect(clipboardWrites, 1);
    expect(copiedText, contains('MULTIPLAYER'));
    expect(copiedText, contains('BATTLE ROYALE'));
    expect(copiedText, contains('GYROSCOPE FIRING SENSITIVITY'));
    expect(copiedText, contains('Vertical Turning Sensitivity: 0'));
    expect(find.text('SYNC COMPLETE'), findsOneWidget);
  });

  testWidgets('MP result excludes unrequested BR display and copy', (tester) async {
    String? copiedText;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copiedText = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(MaterialApp(
      home: SyncResultScreen(
        result: _completeResult(),
        baseSensitivity: 10,
        inputFov: 51,
        selectedRotation: 'fixed',
        requestedMode: 'mp',
        verifyPaidAccess: () async => true,
      ),
    ));
    expect(find.text('BATTLE ROYALE'), findsNothing);
    await tester.tap(find.text('ONE-TAP COPY CONFIG'));
    await tester.pump();

    expect(copiedText, contains('MULTIPLAYER'));
    expect(copiedText, isNot(contains('BATTLE ROYALE')));
  });

  testWidgets('incomplete direct result shows no paid values or copy control', (tester) async {
    var checks = 0;
    await tester.pumpWidget(MaterialApp(
      home: SyncResultScreen(
        result: const {'sync_score': 0},
        baseSensitivity: 10,
        inputFov: 51,
        selectedRotation: 'fixed',
        requestedMode: 'mp',
        verifyPaidAccess: () async {
          checks++;
          return true;
        },
      ),
    ));

    expect(find.text('RESULT UNAVAILABLE'), findsOneWidget);
    expect(find.text('ONE-TAP COPY CONFIG'), findsNothing);
    expect(find.text('SYNC COMPLETE'), findsNothing);
    expect(checks, 0);
  });
}

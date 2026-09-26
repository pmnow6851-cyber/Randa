import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randa_mkcool_aim_sync/screens/sync_result_screen.dart';

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
                  result: const {'sync_score': 0},
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

  testWidgets('a freshly verified result can be copied', (tester) async {
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
      home: SyncResultScreen(
        result: const {'sync_score': 0},
        baseSensitivity: 10,
        inputFov: 51,
        selectedRotation: 'fixed',
        requestedMode: 'mp',
        verifyPaidAccess: () async => true,
      ),
    ));
    await tester.tap(find.text('ONE-TAP COPY CONFIG'));
    await tester.pump();

    expect(clipboardWrites, 1);
    expect(find.text('SYNC COMPLETE'), findsOneWidget);
  });
}

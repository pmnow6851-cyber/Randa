import 'package:flutter_test/flutter_test.dart';
import 'package:randa_mkcool_aim_sync/core/verified_matrix.dart';

const scopes = <String>[
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

List<Map<String, Object>> legacyRows() => [
      for (final scope in scopes)
        {'scope': scope, 'camera': 0, 'firing': 0, 'gyroscope': 0},
    ];

List<Map<String, Object>> section() => [
      for (final scope in scopes) {'label': scope, 'value': 0},
      {'label': 'Vertical Turning Sensitivity', 'value': 0},
    ];

Map<String, Object> completeFullMode() => {
      'camera': section(),
      'firing': section(),
      'gyroscope': section(),
    };

void main() {
  test('accepts the current server sections for the requested mode', () {
    final response = {
      'multiplayer': legacyRows(),
      'full_config': {'multiplayer': completeFullMode()},
    };
    expect(hasCompleteLegacyMatrix(legacyRows()), isTrue);
    expect(hasCompleteAimSyncMatrix(response, 'mp'), isTrue);
    expect(hasCompleteAimSyncMatrix(response, 'br'), isFalse);
  });

  test('requires the current full server configuration', () {
    expect(
      hasCompleteAimSyncMatrix({'multiplayer': legacyRows()}, 'mp'),
      isFalse,
    );
  });

  test('rejects truncated and substituted legacy scopes', () {
    expect(hasCompleteLegacyMatrix(legacyRows().take(8).toList()), isFalse);
    final duplicate = legacyRows();
    duplicate[1]['scope'] = duplicate[0]['scope']!;
    expect(hasCompleteLegacyMatrix(duplicate), isFalse);
    final substituted = legacyRows();
    substituted[1]['scope'] = 'unknown';
    expect(hasCompleteLegacyMatrix(substituted), isFalse);
    final invalid = legacyRows();
    invalid[0]['camera'] = double.infinity;
    expect(hasCompleteLegacyMatrix(invalid), isFalse);
  });

  test('rejects a partial full configuration despite complete legacy rows', () {
    final fullMode = completeFullMode()..remove('firing');
    final response = {
      'multiplayer': legacyRows(),
      'full_config': {'multiplayer': fullMode},
    };
    expect(hasCompleteAimSyncMatrix(response, 'mp'), isFalse);
  });

  test('requires vertical and each named server scope in all sections', () {
    final withoutVertical = completeFullMode();
    (withoutVertical['camera'] as List).removeLast();
    expect(
      hasCompleteAimSyncMatrix({
        'full_config': {'multiplayer': withoutVertical},
      }, 'mp'),
      isFalse,
    );
    final substituted = completeFullMode();
    (substituted['firing'] as List)[0]['label'] = 'unknown';
    expect(
      hasCompleteAimSyncMatrix({
        'full_config': {'multiplayer': substituted},
      }, 'mp'),
      isFalse,
    );
  });

  test('accepts OFF in gyro sections but rejects it in camera', () {
    final fullMode = completeFullMode();
    (fullMode['gyroscope'] as List)[0]['value'] = 'OFF';
    expect(
      hasCompleteAimSyncMatrix({
        'full_config': {'multiplayer': fullMode},
      }, 'mp'),
      isTrue,
    );
    (fullMode['camera'] as List)[0]['value'] = 'OFF';
    expect(
      hasCompleteAimSyncMatrix({
        'full_config': {'multiplayer': fullMode},
      }, 'mp'),
      isFalse,
    );
  });

  test('requires complete camera, firing, and gyro sections for both modes', () {
    final response = {
      'full_config': {
        'multiplayer': completeFullMode(),
        'battle_royale': completeFullMode(),
      },
    };
    expect(hasCompleteAimSyncMatrix(response, 'both'), isTrue);
    (response['full_config'] as Map)['battle_royale'] = {
      'camera': section().take(9).toList(),
      'firing': section(),
      'gyroscope': section(),
    };
    expect(hasCompleteAimSyncMatrix(response, 'both'), isFalse);
    expect(hasCompleteAimSyncMatrix(response, 'mp'), isTrue);
  });
}

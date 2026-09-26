import 'package:flutter_test/flutter_test.dart';
import 'package:randa_mkcool_aim_sync/core/verified_matrix.dart';

List<Map<String, Object>> legacyRows() => List.generate(
      9,
      (i) => {
        'scope': 'scope_$i',
        'camera': 0,
        'firing': 0,
        'gyroscope': 0,
      },
    );

List<Map<String, Object>> section() => List.generate(
      9,
      (i) => {'label': 'scope_$i', 'value': 0},
    );

Map<String, Object> completeFullMode() => {
      'camera': section(),
      'firing': section(),
      'gyroscope': section(),
    };

void main() {
  test('a complete legacy matrix supports the requested mode', () {
    final response = {'multiplayer': legacyRows()};
    expect(hasCompleteAimSyncMatrix(response, 'mp'), isTrue);
    expect(hasCompleteAimSyncMatrix(response, 'br'), isFalse);
  });

  test('rejects a truncated legacy matrix', () {
    expect(
      hasCompleteAimSyncMatrix({'multiplayer': legacyRows().take(1).toList()}, 'mp'),
      isFalse,
    );
  });

  test('rejects duplicate scopes and invalid values', () {
    final duplicate = legacyRows();
    duplicate[1]['scope'] = duplicate[0]['scope']!;
    expect(hasCompleteLegacyMatrix(duplicate), isFalse);

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

  test('requires complete camera, firing, and gyro sections for both modes', () {
    final response = {
      'full_config': {
        'multiplayer': completeFullMode(),
        'battle_royale': completeFullMode(),
      },
    };
    expect(hasCompleteAimSyncMatrix(response, 'both'), isTrue);
    (response['full_config'] as Map)['battle_royale'] = {
      'camera': section().take(8).toList(),
      'firing': section(),
      'gyroscope': section(),
    };
    expect(hasCompleteAimSyncMatrix(response, 'both'), isFalse);
    expect(hasCompleteAimSyncMatrix(response, 'mp'), isTrue);
  });
}

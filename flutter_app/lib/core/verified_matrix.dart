/// Client-side shape check for a paid configuration returned by the server.
///
/// This validates display completeness only. Entitlement and the calculation
/// remain authoritative on the server.
const _scopeLabels = <String>{
  'standard',
  'red dot / holo',
  'ads',
  'tactical scope',
  '3x',
  '4x',
  '6x',
  '8x',
  'sniper',
};
const _sectionLabels = <String>{
  ..._scopeLabels,
  'vertical turning sensitivity',
};

bool _validNumber(dynamic value) =>
    value is num && value.isFinite && value >= 0;

bool _completeRows(
  dynamic rows, {
  required Set<String> expectedLabels,
  required String? Function(Map) labelFor,
  required bool Function(Map) validValues,
}) {
  if (rows is! List || rows.length != expectedLabels.length) return false;
  final labels = <String>{};
  for (final row in rows) {
    if (row is! Map || !validValues(row)) return false;
    final label = labelFor(row)?.trim().toLowerCase();
    if (label == null || !expectedLabels.contains(label) || !labels.add(label)) {
      return false;
    }
  }
  return labels.length == expectedLabels.length;
}

bool hasCompleteLegacyMatrix(dynamic rows) => _completeRows(
      rows,
      expectedLabels: _scopeLabels,
      labelFor: (row) => row['scope'] is String ? row['scope'] as String : null,
      validValues: (row) =>
          _validNumber(row['camera']) &&
          _validNumber(row['firing']) &&
          _validNumber(row['gyroscope']),
    );

bool _hasCompleteSection(dynamic rows, {required bool allowGyroOff}) =>
    _completeRows(
      rows,
      expectedLabels: _sectionLabels,
      labelFor: (row) {
        final label = row['label'] ?? row['scope'] ?? row['name'];
        return label is String ? label : null;
      },
      validValues: (row) =>
          _validNumber(row['value']) ||
          (allowGyroOff && row['value'] == 'OFF'),
    );

bool _hasCompleteMode(Map<String, dynamic> data, String key) {
  final full = data['full_config'];
  if (full is! Map || full[key] is! Map) return false;
  final config = full[key] as Map;
  return _hasCompleteSection(config['camera'], allowGyroOff: false) &&
      _hasCompleteSection(config['firing'], allowGyroOff: false) &&
      _hasCompleteSection(config['gyroscope'], allowGyroOff: true);
}

bool hasCompleteAimSyncMatrix(
  Map<String, dynamic> data,
  String requestedMode,
) {
  switch (requestedMode) {
    case 'mp':
      return _hasCompleteMode(data, 'multiplayer');
    case 'br':
      return _hasCompleteMode(data, 'battle_royale');
    case 'both':
      return _hasCompleteMode(data, 'multiplayer') &&
          _hasCompleteMode(data, 'battle_royale');
    default:
      return false;
  }
}

/// Client-side shape check for a paid configuration returned by the server.
///
/// This validates display completeness only. Entitlement and the calculation
/// remain authoritative on the server.
const _minimumScopes = 9;

bool _validNumber(dynamic value) =>
    value is num && value.isFinite && value >= 0;

bool _completeRows(
  dynamic rows, {
  required String? Function(Map) labelFor,
  required bool Function(Map) validValues,
}) {
  if (rows is! List || rows.length < _minimumScopes) return false;
  final labels = <String>{};
  for (final row in rows) {
    if (row is! Map || !validValues(row)) return false;
    final label = labelFor(row);
    if (label == null || label.trim().isEmpty ||
        !labels.add(label.trim().toLowerCase())) {
      return false;
    }
  }
  return true;
}

bool hasCompleteLegacyMatrix(dynamic rows) => _completeRows(
      rows,
      labelFor: (row) => row['scope'] is String ? row['scope'] as String : null,
      validValues: (row) =>
          _validNumber(row['camera']) &&
          _validNumber(row['firing']) &&
          _validNumber(row['gyroscope']),
    );

bool _hasCompleteSection(dynamic rows) => _completeRows(
      rows,
      labelFor: (row) {
        final label = row['label'] ?? row['scope'] ?? row['name'];
        return label is String ? label : null;
      },
      validValues: (row) => _validNumber(row['value']),
    );

bool _hasCompleteMode(Map<String, dynamic> data, String key) {
  final full = data['full_config'];
  if (full is Map && full.containsKey(key)) {
    final config = full[key];
    if (config is! Map) return false;
    return _hasCompleteSection(config['camera']) &&
        _hasCompleteSection(config['firing']) &&
        _hasCompleteSection(config['gyroscope']);
  }
  return hasCompleteLegacyMatrix(data[key]);
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

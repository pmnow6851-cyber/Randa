import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SyncResultScreen extends StatelessWidget {
  const SyncResultScreen({
    super.key,
    required this.result,
    required this.baseSensitivity,
    required this.inputFov,
    required this.selectedRotation,
    required this.requestedMode,
  });

  final Map<String, dynamic> result;
  final int baseSensitivity;
  final int inputFov;
  final String selectedRotation;
  final String requestedMode;

  static const _background = Color(0xFF050A0E);
  static const _surface = Color(0xFF0D1A24);
  static const _surfaceRaised = Color(0xFF122432);
  static const _accent = Color(0xFF1AFFC6);
  static const _cyan = Color(0xFF00E5FF);
  static const _muted = Color(0xFF8AA3B0);

  String _rotationLabel(String value) => switch (value) {
        'speed' => 'Speed Acceleration',
        'distance' => 'Distance Acceleration',
        _ => 'Fixed Speed',
      };

  Map<String, dynamic>? _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  List<Map<String, dynamic>> _maps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => row.map((key, val) => MapEntry(key.toString(), val)))
        .toList();
  }

  List<_ResultEntry> _entries(dynamic value) {
    final rows = _maps(value);
    return rows
        .map((row) {
          final label = row['label']?.toString() ??
              row['scope']?.toString() ??
              row['name']?.toString() ??
              '';
          final rawValue = row['value'];
          if (label.isEmpty || rawValue == null) return null;
          return _ResultEntry(label, rawValue.toString());
        })
        .whereType<_ResultEntry>()
        .toList();
  }

  List<_ResultEntry> _legacyEntries(
    dynamic rows,
    String valueKey,
  ) {
    return _maps(rows)
        .map((row) {
          final label = row['scope']?.toString() ?? '';
          final value = row[valueKey];
          if (label.isEmpty || value == null) return null;
          return _ResultEntry(
            label,
            valueKey.startsWith('gyro') && value == 0
                ? 'OFF'
                : value.toString(),
          );
        })
        .whereType<_ResultEntry>()
        .toList();
  }

  Map<String, dynamic>? _fullModeConfig(String key) {
    final full = _map(result['full_config']);
    return full == null ? null : _map(full[key]);
  }

  List<_ResultSection> _sectionsForMode(
    String key,
    dynamic legacyRows,
  ) {
    final config = _fullModeConfig(key);

    final rotation = _entries(config?['rotation']);
    final fov = _entries(config?['fov']);
    final freeView = _entries(config?['free_view']);
    final camera = _entries(config?['camera']);
    final firing = _entries(config?['firing']);
    final gyro = _entries(config?['gyroscope']);
    final gyroFiring = _entries(config?['gyroscope_firing']);

    return [
      _ResultSection(
        'ROTATION',
        rotation.isNotEmpty
            ? rotation
            : [_ResultEntry('Selected Mode', _rotationLabel(selectedRotation))],
      ),
      _ResultSection(
        'FOV',
        fov.isNotEmpty
            ? fov
            : [_ResultEntry('Input FOV', inputFov.toString())],
      ),
      if (freeView.isNotEmpty)
        _ResultSection('FREE VIEW SENSITIVITY', freeView),
      _ResultSection(
        'CAMERA SENSITIVITY',
        camera.isNotEmpty
            ? camera
            : _legacyEntries(legacyRows, 'camera'),
      ),
      _ResultSection(
        'FIRING SENSITIVITY',
        firing.isNotEmpty
            ? firing
            : _legacyEntries(legacyRows, 'firing'),
      ),
      _ResultSection(
        'GYROSCOPE SENSITIVITY',
        gyro.isNotEmpty
            ? gyro
            : _legacyEntries(legacyRows, 'gyroscope'),
      ),
      if (gyroFiring.isNotEmpty)
        _ResultSection('GYROSCOPE FIRING SENSITIVITY', gyroFiring),
    ];
  }

  bool get _showMp =>
      requestedMode == 'mp' ||
      requestedMode == 'both' ||
      result['multiplayer'] is List;

  bool get _showBr =>
      requestedMode == 'br' ||
      requestedMode == 'both' ||
      result['battle_royale'] is List;

  String _copyText() {
    final buffer = StringBuffer()
      ..writeln('🎯 RANDA.MKCOOL AIM SYNC')
      ..writeln('Sync Score: ${result['sync_score'] ?? '-'} / 100')
      ..writeln('Base Sensitivity: $baseSensitivity')
      ..writeln('Input FOV: $inputFov')
      ..writeln('============================')
      ..writeln();

    void addMode(
      String title,
      String key,
      dynamic legacyRows,
    ) {
      buffer.writeln(title);
      buffer.writeln('----------------------------');
      for (final section in _sectionsForMode(key, legacyRows)) {
        buffer.writeln(section.title);
        for (final entry in section.entries) {
          buffer.writeln('${entry.label}: ${entry.value}');
        }
        buffer.writeln();
      }
    }

    if (_showMp) {
      addMode(
        'MULTIPLAYER',
        'multiplayer',
        result['multiplayer'],
      );
    }

    if (_showBr) {
      addMode(
        'BATTLE ROYALE',
        'battle_royale',
        result['battle_royale'],
      );
    }

    buffer
      ..writeln('============================')
      ..writeln('YOUR AIM ISN\'T BAD. IT\'S UNSYNCED.');

    return buffer.toString();
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      await Clipboard.setData(
        ClipboardData(text: _copyText()),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: _accent,
            content: Text(
              'CONFIG COPIED TO CLIPBOARD',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(
              'COPY FAILED — TRY AGAIN',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SYNC COMPLETE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: _accent,
                    size: 60,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'YOUR FULL AIM SYNC',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'SYNC SCORE ${result['sync_score'] ?? '-'} / 100',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_showMp)
                    _GameModePanel(
                      title: 'MULTIPLAYER',
                      sections: _sectionsForMode(
                        'multiplayer',
                        result['multiplayer'],
                      ),
                    ),
                  if (_showMp && _showBr) const SizedBox(height: 20),
                  if (_showBr)
                    _GameModePanel(
                      title: 'BATTLE ROYALE',
                      sections: _sectionsForMode(
                        'battle_royale',
                        result['battle_royale'],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: _background,
                border: Border(
                  top: BorderSide(color: Colors.white12),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text(
                        'ONE-TAP COPY CONFIG',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: .6,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'START OVER',
                      style: TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameModePanel extends StatelessWidget {
  const _GameModePanel({
    required this.title,
    required this.sections,
  });

  final String title;
  final List<_ResultSection> sections;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SyncResultScreen._surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1D3847)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: const BoxDecoration(
              color: SyncResultScreen._surfaceRaised,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: SyncResultScreen._accent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          for (final section in sections)
            if (section.entries.isNotEmpty)
              _SectionBlock(section: section),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.section,
  });

  final _ResultSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in section.entries)
            _ValueRow(entry: entry),
          const Divider(
            height: 20,
            color: Colors.white10,
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.entry,
  });

  final _ResultEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.label,
              style: const TextStyle(
                color: SyncResultScreen._muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              entry.value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: SyncResultScreen._accent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSection {
  const _ResultSection(this.title, this.entries);

  final String title;
  final List<_ResultEntry> entries;
}

class _ResultEntry {
  const _ResultEntry(this.label, this.value);

  final String label;
  final String value;
}

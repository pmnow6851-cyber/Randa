import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RandaAimSyncApp());
}

class RandaAimSyncApp extends StatelessWidget {
  const RandaAimSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF071018);
    const card = Color(0xFF0D1A24);
    const cyan = Color(0xFF00E5FF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RANDA.MKCOOL Aim Sync',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: Color(0xFF1AFFC6),
          surface: card,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF08151E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF274454)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF274454)),
          ),
        ),
      ),
      home: const AimSyncHome(),
    );
  }
}

class AimSyncHome extends StatefulWidget {
  const AimSyncHome({super.key});

  @override
  State<AimSyncHome> createState() => _AimSyncHomeState();
}

class _AimSyncHomeState extends State<AimSyncHome>
    with WidgetsBindingObserver {
  static const _supabaseUrl = 'https://nnlckidhrsnodjulydpd.supabase.co';
  static const _supabaseKey =
      'sb_publishable_0m6qlAuHl3xa1UEhyMtr1Q_Pagypmb9';
  static const _clientHeaderValue = 'mobile';
  static const _canonicalOrigin = 'https://pmnow6851-cyber.github.io';

  static const _checkoutUrl =
      '$_supabaseUrl/functions/v1/create-checkout-session';
  static const _calcUrl = '$_supabaseUrl/functions/v1/calculate-aim-sync';
  static const _healthUrl = '$_supabaseUrl/functions/v1/system-health';

  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'randa_access_token_v1';
  static const _refreshKey = 'randa_refresh_token_v1';

  final _email = TextEditingController();
  final _password = TextEditingController();

  String _accessToken = '';
  String _refreshToken = '';
  String _userId = '';
  String _userEmail = '';

  bool _busy = false;
  bool _systemOnline = false;
  bool _signedIn = false;
  bool _isPro = false;
  bool _checkingAccess = true;

  double _base = 126;
  double _fov = 70;
  String _mode = 'both';
  String _device = 'medium';
  String _rotation = 'fixed';
  String _playstyle = 'balanced';
  String _gyro = 'off';

  Map<String, dynamic>? _result;
  Timer? _calcDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _calcDebounce?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _signedIn) {
      unawaited(_refreshAccessAndMaybeCalculate());
    }
  }

  Future<void> _bootstrap() async {
    await _checkHealth();
    _accessToken = await _storage.read(key: _accessKey) ?? '';
    _refreshToken = await _storage.read(key: _refreshKey) ?? '';
    if (_accessToken.isNotEmpty) {
      await _restoreSession();
    }
    if (mounted) setState(() => _checkingAccess = false);
  }

  Map<String, String> _headers({bool authenticated = false}) => {
        'apikey': _supabaseKey,
        'content-type': 'application/json',
        'origin': _canonicalOrigin,
        'x-randa-client': _clientHeaderValue,
        if (authenticated && _accessToken.isNotEmpty)
          'authorization': 'Bearer $_accessToken',
      };

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    dynamic parsed;
    try {
      parsed = jsonDecode(response.body);
    } catch (_) {
      parsed = <String, dynamic>{'error': 'invalid_server_response'};
    }
    final data = parsed is Map<String, dynamic>
        ? parsed
        : <String, dynamic>{'data': parsed};
    data['_status'] = response.statusCode;
    return data;
  }

  Future<void> _saveTokens(Map<String, dynamic>? data) async {
    _accessToken = data?['access_token']?.toString() ?? '';
    _refreshToken = data?['refresh_token']?.toString() ?? '';
    if (_accessToken.isEmpty) {
      await _storage.delete(key: _accessKey);
    } else {
      await _storage.write(key: _accessKey, value: _accessToken);
    }
    if (_refreshToken.isEmpty) {
      await _storage.delete(key: _refreshKey);
    } else {
      await _storage.write(key: _refreshKey, value: _refreshToken);
    }
  }

  Future<bool> _refreshSession() async {
    if (_refreshToken.isEmpty) return false;
    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=refresh_token'),
        headers: _headers(),
        body: jsonEncode({'refresh_token': _refreshToken}),
      );
      final data = await _decode(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }
      await _saveTokens(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(_healthUrl),
        headers: {'cache-control': 'no-store'},
      );
      final data = await _decode(response);
      if (mounted) {
        setState(() {
          _systemOnline = response.statusCode == 200 && data['ok'] == true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _systemOnline = false);
    }
  }

  Future<Map<String, dynamic>?> _getUser() async {
    if (_accessToken.isEmpty) return null;
    Future<http.Response> call() => http.get(
          Uri.parse('$_supabaseUrl/auth/v1/user'),
          headers: _headers(authenticated: true),
        );
    var response = await call();
    if (response.statusCode == 401 && await _refreshSession()) {
      response = await call();
    }
    if (response.statusCode != 200) return null;
    final data = await _decode(response);
    return data;
  }

  Future<bool> _checkEntitlement() async {
    if (_userId.isEmpty || _accessToken.isEmpty) return false;
    final query = Uri.encodeQueryComponent(_userId);
    final uri = Uri.parse(
      '$_supabaseUrl/rest/v1/access_entitlements?select=tier,status&user_id=eq.$query&limit=1',
    );
    Future<http.Response> call() => http.get(
          uri,
          headers: _headers(authenticated: true),
        );
    var response = await call();
    if (response.statusCode == 401 && await _refreshSession()) {
      response = await call();
    }
    if (response.statusCode != 200) return false;
    final parsed = jsonDecode(response.body);
    if (parsed is! List || parsed.isEmpty) return false;
    final row = parsed.first;
    return row is Map && row['tier'] == 'pro' && row['status'] == 'active';
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _getUser();
      if (user == null || user['id'] == null) {
        await _saveTokens(null);
        if (mounted) {
          setState(() {
            _signedIn = false;
            _isPro = false;
            _userId = '';
            _userEmail = '';
            _result = null;
          });
        }
        return;
      }
      _userId = user['id'].toString();
      _userEmail = user['email']?.toString() ?? '';
      final pro = await _checkEntitlement();
      if (mounted) {
        setState(() {
          _signedIn = true;
          _isPro = pro;
        });
      }
      if (pro) await _calculate();
    } catch (_) {
      if (mounted) _snack('Could not restore the account session.');
    }
  }

  Future<void> _signUp() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (!email.contains('@') || password.length < 8) {
      _snack('Enter a valid email and an 8+ character password.');
      return;
    }
    await _withBusy(() async {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/signup'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = await _decode(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(_errorText(data, 'Account creation failed'));
      }
      if (data['access_token'] != null) {
        await _saveTokens(data);
        await _restoreSession();
        _snack('Account created. Paid unlock is still required.');
      } else {
        _snack('Account created. Confirm your email, then sign in.');
      }
    });
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _snack('Enter your email and password.');
      return;
    }
    await _withBusy(() async {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=password'),
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = await _decode(response);
      if (response.statusCode != 200) {
        throw Exception(_errorText(data, 'Sign-in failed'));
      }
      await _saveTokens(data);
      await _restoreSession();
      _snack(_isPro ? 'Paid access restored.' : 'Signed in. Unlock required.');
    });
  }

  Future<void> _signOut() async {
    try {
      if (_accessToken.isNotEmpty) {
        await http.post(
          Uri.parse('$_supabaseUrl/auth/v1/logout'),
          headers: _headers(authenticated: true),
        );
      }
    } catch (_) {}
    await _saveTokens(null);
    if (!mounted) return;
    setState(() {
      _signedIn = false;
      _isPro = false;
      _userId = '';
      _userEmail = '';
      _result = null;
    });
    _snack('Signed out.');
  }

  Future<void> _refreshAccessAndMaybeCalculate() async {
    if (!_signedIn) return;
    final pro = await _checkEntitlement();
    if (!mounted) return;
    setState(() => _isPro = pro);
    if (pro) {
      await _calculate();
    }
  }

  Future<void> _startCheckout() async {
    if (!_systemOnline) {
      _snack('System check failed. No payment has been taken.');
      return;
    }
    if (!_signedIn) {
      _snack('Create an account or sign in first.');
      return;
    }
    if (_isPro) {
      _snack('Paid access is already active.');
      return;
    }

    await _withBusy(() async {
      Future<http.Response> call() => http.post(
            Uri.parse(_checkoutUrl),
            headers: _headers(authenticated: true),
            body: jsonEncode({'client': 'mobile'}),
          );
      var response = await call();
      if (response.statusCode == 401 && await _refreshSession()) {
        response = await call();
      }
      final data = await _decode(response);
      if (response.statusCode != 200) {
        throw Exception(_errorText(data, 'Checkout unavailable'));
      }
      if (data['alreadyPro'] == true) {
        if (mounted) setState(() => _isPro = true);
        await _calculate();
        return;
      }
      final checkout = data['url']?.toString() ?? '';
      final uri = Uri.tryParse(checkout);
      if (uri == null || uri.scheme != 'https') {
        throw Exception('Checkout link missing');
      }
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) throw Exception('Could not open secure checkout');
      _snack('Complete payment in your browser, then return here.');
    });
  }

  Map<String, dynamic> _payload() => {
        'base': _base.round(),
        'fov': _fov.round(),
        'mode': _mode,
        'device': _device,
        'rotation': _rotation,
        'playstyle': _playstyle,
        'gyro': _gyro,
      };

  Future<void> _calculate() async {
    if (!_isPro || _accessToken.isEmpty) return;
    try {
      Future<http.Response> call() => http.post(
            Uri.parse(_calcUrl),
            headers: _headers(authenticated: true),
            body: jsonEncode(_payload()),
          );
      var response = await call();
      if (response.statusCode == 401 && await _refreshSession()) {
        response = await call();
      }
      final data = await _decode(response);
      if (response.statusCode == 402) {
        if (mounted) {
          setState(() {
            _isPro = false;
            _result = null;
          });
        }
        _snack('Paid access is not active.');
        return;
      }
      if (response.statusCode != 200) {
        throw Exception(_errorText(data, 'Calculation failed'));
      }
      if (mounted) setState(() => _result = data);
    } catch (e) {
      if (mounted) _snack(_cleanException(e));
    }
  }

  void _scheduleCalculation() {
    if (!_isPro) return;
    _calcDebounce?.cancel();
    _calcDebounce = Timer(const Duration(milliseconds: 350), _calculate);
  }

  Future<void> _copyConfig() async {
    if (!_isPro || _result == null) return;
    await Clipboard.setData(ClipboardData(text: _configText()));
    _snack('Complete paid config copied.');
  }

  String _configText() {
    final result = _result!;
    final lines = <String>[
      'RANDA.MKCOOL AIM SYNC CONFIG',
      'Sync Score: ${result['sync_score']}/100',
      'Base Sensitivity: ${_base.round()}',
      'FOV: ${_fov.round()}',
      'Rotation: ${_rotationLabel(_rotation)}',
      '',
    ];

    void add(String title, dynamic rawRows) {
      if (rawRows is! List) return;
      lines.add(title);
      lines.add('SCOPE | CAMERA | FIRING | GYRO');
      for (final raw in rawRows) {
        if (raw is! Map) continue;
        final gyro = raw['gyroscope'];
        lines.add(
          '${raw['scope']} | ${raw['camera']} | ${raw['firing']} | ${gyro == 0 ? 'OFF' : gyro}',
        );
      }
      lines.add('');
    }

    add('MULTIPLAYER', result['multiplayer']);
    add('BATTLE ROYALE', result['battle_royale']);
    return lines.join('\n');
  }

  Future<void> _withBusy(Future<void> Function() action) async {
    if (_busy) return;
    if (mounted) setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) _snack(_cleanException(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _errorText(Map<String, dynamic> data, String fallback) {
    return data['error_description']?.toString() ??
        data['message']?.toString() ??
        data['msg']?.toString() ??
        data['error']?.toString() ??
        fallback;
  }

  String _cleanException(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _rotationLabel(String value) => switch (value) {
        'speed' => 'Speed Acceleration',
        'distance' => 'Distance Acceleration',
        _ => 'Fixed Speed',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RANDA.MKCOOL', style: TextStyle(fontWeight: FontWeight.w900)),
            Text('AIM SYNC SYSTEM', style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          _StatusChip(
            text: _systemOnline ? 'SYSTEM ONLINE' : 'SYSTEM CHECK',
            ok: _systemOnline,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkHealth();
          await _refreshAccessAndMaybeCalculate();
        },
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _hero(),
            const SizedBox(height: 14),
            _accountCard(),
            const SizedBox(height: 14),
            if (!_isPro) ...[
              _unlockCard(),
              const SizedBox(height: 14),
              const AdBannerPlaceholder(),
              const SizedBox(height: 14),
            ],
            if (_checkingAccess)
              const _Panel(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (!_isPro)
              _lockedCalculator()
            else
              _calculator(),
            const SizedBox(height: 14),
            const Text(
              'Unofficial CODM sensitivity utility. Not affiliated with, endorsed by, or sponsored by Activision, Call of Duty, Tencent, or TiMi Studio Group. Test changes in training before treating any profile as final.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8AA3B0), fontSize: 11, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() => _Panel(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Your aim isn’t bad.\nIt’s unsynced.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.05),
              ),
              SizedBox(height: 10),
              Text(
                'Paid Aim Sync builds a repeatable CODM sensitivity profile around your inputs while keeping the calculation engine private.',
                style: TextStyle(color: Color(0xFF8AA3B0), height: 1.45),
              ),
            ],
          ),
        ),
      );

  Widget _accountCard() => _Panel(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('ACCOUNT'),
              if (_signedIn) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_isPro ? 'PAID ACCESS ACTIVE' : 'SIGNED IN'),
                  subtitle: Text(_userEmail.isEmpty ? 'Account active' : _userEmail),
                  trailing: TextButton(onPressed: _busy ? null : _signOut, child: const Text('SIGN OUT')),
                ),
              ] else ...[
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy ? null : _signIn,
                        child: const Text('SIGN IN'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy ? null : _signUp,
                        child: const Text('CREATE ACCOUNT'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );

  Widget _unlockCard() => _Panel(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('ONE-TIME UNLOCK'),
              const Text(
                '£9.99',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF1AFFC6)),
              ),
              const Text('ONE-TIME PAYMENT', style: TextStyle(color: Color(0xFF8AA3B0))),
              const SizedBox(height: 12),
              const _Feature('Full MP + BR sensitivity matrix'),
              const _Feature('Camera, firing and gyroscope values'),
              const _Feature('One-tap copy configuration'),
              const _Feature('Account-based paid access restoration'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy || !_systemOnline ? null : _startCheckout,
                  child: Text(_busy ? 'WORKING…' : 'UNLOCK AIM SYNC • £9.99'),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Secure checkout opens in your browser. After payment, return to this app and access is rechecked automatically.',
                style: TextStyle(color: Color(0xFF8AA3B0), fontSize: 12),
              ),
            ],
          ),
        ),
      );

  Widget _lockedCalculator() => _Panel(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
          child: Column(
            children: [
              const Icon(Icons.lock_outline, size: 46, color: Color(0xFF00E5FF)),
              const SizedBox(height: 12),
              const Text('PAID ACCESS REQUIRED', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'The sensitivity engine, controls, and generated values stay locked until the £9.99 payment is verified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8AA3B0)),
              ),
              const SizedBox(height: 14),
              FilledButton(onPressed: _busy ? null : _startCheckout, child: const Text('UNLOCK • £9.99')),
            ],
          ),
        ),
      );

  Widget _calculator() => _Panel(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('AIM SYNC CALCULATOR'),
              _SliderControl(
                label: 'Standard Base Sensitivity',
                value: _base,
                min: 10,
                max: 300,
                onChanged: (value) {
                  setState(() => _base = value);
                  _scheduleCalculation();
                },
              ),
              _SliderControl(
                label: 'Field of View (FOV)',
                value: _fov,
                min: 51,
                max: 90,
                onChanged: (value) {
                  setState(() => _fov = value);
                  _scheduleCalculation();
                },
              ),
              _drop(
                label: 'Rotation Mode',
                value: _rotation,
                items: const {
                  'fixed': 'Fixed Speed',
                  'speed': 'Speed Acceleration',
                  'distance': 'Distance Acceleration',
                },
                onChanged: (v) => _setAndRecalc(() => _rotation = v),
              ),
              _drop(
                label: 'Game Mode',
                value: _mode,
                items: const {'both': 'Multiplayer + Battle Royale', 'mp': 'Multiplayer', 'br': 'Battle Royale'},
                onChanged: (v) => _setAndRecalc(() => _mode = v),
              ),
              _drop(
                label: 'Device Profile',
                value: _device,
                items: const {'medium': 'Medium Phone', 'small': 'Small Phone', 'large': 'Large Phone', 'tablet': 'Tablet'},
                onChanged: (v) => _setAndRecalc(() => _device = v),
              ),
              _drop(
                label: 'Playstyle',
                value: _playstyle,
                items: const {'balanced': 'Balanced', 'aggressive': 'Aggressive', 'tactical': 'Tactical'},
                onChanged: (v) => _setAndRecalc(() => _playstyle = v),
              ),
              _drop(
                label: 'Gyroscope',
                value: _gyro,
                items: const {'off': 'Off', 'ads': 'ADS Only', 'always': 'Always On'},
                onChanged: (v) => _setAndRecalc(() => _gyro = v),
              ),
              const SizedBox(height: 12),
              if (_result == null)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else ...[
                Text(
                  'SYNC SCORE ${_result!['sync_score']} / 100',
                  style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                if (_result!['multiplayer'] is List)
                  _ResultTable(title: 'MULTIPLAYER', rows: _result!['multiplayer'] as List),
                if (_result!['battle_royale'] is List)
                  _ResultTable(title: 'BATTLE ROYALE', rows: _result!['battle_royale'] as List),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _copyConfig,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('ONE-TAP COPY CONFIG'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _drop({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  void _setAndRecalc(VoidCallback setter) {
    setState(setter);
    _scheduleCalculation();
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1A24),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1D3847)),
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7)),
      );
}

class _StatusChip extends StatelessWidget {
  final String text;
  final bool ok;
  const _StatusChip({required this.text, required this.ok});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Chip(
          avatar: Icon(Icons.circle, size: 10, color: ok ? const Color(0xFF55F09B) : const Color(0xFFFF657D)),
          label: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          side: const BorderSide(color: Color(0xFF1D3847)),
        ),
      );
}

class _Feature extends StatelessWidget {
  final String text;
  const _Feature(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Row(
          children: [
            const Icon(Icons.check, size: 18, color: Color(0xFF55F09B)),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _SliderControl extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderControl({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                Chip(label: Text(value.round().toString())),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ],
        ),
      );
}

class _ResultTable extends StatelessWidget {
  final String title;
  final List rows;
  const _ResultTable({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('SCOPE')),
                DataColumn(label: Text('CAM'), numeric: true),
                DataColumn(label: Text('FIRE'), numeric: true),
                DataColumn(label: Text('GYRO'), numeric: true),
              ],
              rows: rows.whereType<Map>().map((row) {
                final gyro = row['gyroscope'];
                return DataRow(cells: [
                  DataCell(Text(row['scope']?.toString() ?? '')),
                  DataCell(Text(row['camera']?.toString() ?? '')),
                  DataCell(Text(row['firing']?.toString() ?? '')),
                  DataCell(Text(gyro == 0 ? 'OFF' : gyro?.toString() ?? 'OFF')),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => _Panel(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: const Column(
            children: [
              Icon(Icons.ads_click_outlined, color: Color(0xFF8AA3B0)),
              SizedBox(height: 6),
              Text('ADMOB BANNER SLOT', style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text(
                'Drop the production BannerAd widget here after your AdMob app and ad-unit IDs are issued. Never commit private account or bank details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8AA3B0), fontSize: 11),
              ),
            ],
          ),
        ),
      );
}

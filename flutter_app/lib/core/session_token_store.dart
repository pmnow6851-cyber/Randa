import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps production session tokens in platform secure storage.
abstract interface class SessionTokenStore {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
}

final class SecureSessionTokenStore implements SessionTokenStore {
  const SecureSessionTokenStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}

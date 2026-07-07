import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'jlw_token';
  static const _keyUsername = 'jlw_username';
  static const _keyEnvironment = 'jlw_environment';
  static const _keyRole = 'jlw_role';

  static const _keyCredUsername = 'jlw_cred_username';
  static const _keyCredPassword = 'jlw_cred_password';
  static const _keyBiometricEnabled = 'jlw_biometric_enabled';

  Future<void> saveSession({
    required String token,
    required String username,
    String environment = '',
    String role = '',
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(key: _keyUsername, value: username),
      _storage.write(key: _keyEnvironment, value: environment),
      _storage.write(key: _keyRole, value: role),
    ]);
  }

  Future<({String token, String username, String environment, String role})?> loadSession() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null || token.isEmpty) return null;
    return (
      token: token,
      username: await _storage.read(key: _keyUsername) ?? '',
      environment: await _storage.read(key: _keyEnvironment) ?? '',
      role: await _storage.read(key: _keyRole) ?? '',
    );
  }

  /// Clears only the active session (token/profile), leaving any saved
  /// biometric credentials in place so fast sign-in keeps working.
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyUsername),
      _storage.delete(key: _keyEnvironment),
      _storage.delete(key: _keyRole),
    ]);
  }

  /// Persists the username/password used for biometric sign-in.
  /// Backed by FlutterSecureStorage, which stores values in the Android
  /// Keystore-backed EncryptedSharedPreferences / iOS Keychain.
  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    await Future.wait([
      _storage.write(key: _keyCredUsername, value: username),
      _storage.write(key: _keyCredPassword, value: password),
    ]);
  }

  Future<({String username, String password})?> loadCredentials() async {
    final username = await _storage.read(key: _keyCredUsername);
    final password = await _storage.read(key: _keyCredPassword);
    if (username == null || password == null) return null;
    return (username: username, password: password);
  }

  Future<void> clearCredentials() async {
    await Future.wait([
      _storage.delete(key: _keyCredUsername),
      _storage.delete(key: _keyCredPassword),
      _storage.delete(key: _keyBiometricEnabled),
    ]);
  }

  Future<bool> isBiometricEnabled() async {
    return await _storage.read(key: _keyBiometricEnabled) == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }
}

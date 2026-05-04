
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _accesSession = 'access_session';
  static const _userInfo = "user_info";
  static const _accessToken = 'access_token';
  late final FlutterSecureStorage _storage;

  SecureStorageHelper._(this._storage);

  static final SecureStorageHelper _instance = SecureStorageHelper._(
    const FlutterSecureStorage(),
  );

  static SecureStorageHelper get instance => _instance;

  Future<String?> getToken() async {
    final token = await _storage.read(key: _accessToken);
    if (token != null) {
      return token;
    }
    return null;
  }

  Future<void> saveAccessToken(String? token) async {
    await _storage.write(key: _accessToken, value: token);
  }

  Future<void> clearAccessToken() async {
    await _storage.delete(key: _accessToken);
  }
}

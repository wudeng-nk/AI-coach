import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userNameKey = 'user_name';
  static const _userPhoneKey = 'user_phone';
  static const _userRoleKey = 'user_role';
  static const _userAvatarKey = 'user_avatar';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Tokens
  Future<void> setTokens(String accessToken, String refreshToken) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    return (await _prefs).getString(_accessTokenKey);
  }

  Future<void> clearTokens() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // User info cache
  Future<void> saveUserInfo({String? name, String? phone, String? role, String? avatar}) async {
    final prefs = await _prefs;
    if (name != null) await prefs.setString(_userNameKey, name);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
    if (role != null) await prefs.setString(_userRoleKey, role);
    if (avatar != null) await prefs.setString(_userAvatarKey, avatar);
  }

  Future<String?> getUserName() async => (await _prefs).getString(_userNameKey);
  Future<String?> getUserPhone() async => (await _prefs).getString(_userPhoneKey);

  Future<bool> isLoggedIn() async => (await _prefs).getString(_accessTokenKey) != null;

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}

final localStorage = LocalStorage();

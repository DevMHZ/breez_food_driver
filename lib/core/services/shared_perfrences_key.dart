import 'dart:convert';

import 'package:hive/hive.dart';

class AuthStorageHelper {
  static const String _authBoxName = 'auth_box';
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _isGuestKey = 'is_guest';
  static const String _latKey = 'user_lat';
  static const String _lonKey = 'user_lon';
  static const String _prefsBoxName = 'app_prefs_box';
  static const String _zoomHintKey = 'verify_zoom_hint_dismissed_v1';
  static const String acceptConditionKey = 'accept_condition';
  static const String manualOfflineKey = 'manual_offline_v1';
static const String _activeOrderKey = "active_order_v1"; 
static const String _activeOrderIdKey = "active_order_id_v1"; 

static Future<void> saveActiveOrder({
  required int orderId,
  Map<String, dynamic>? orderSnapshot,
}) async {
  final box = await Hive.openBox(_prefsBoxName);
  await box.put(_activeOrderIdKey, orderId);
  if (orderSnapshot != null) {
    await box.put(_activeOrderKey, jsonEncode(orderSnapshot));
  }
}

static Future<int?> getActiveOrderId() async {
  final box = await Hive.openBox(_prefsBoxName);
  final v = box.get(_activeOrderIdKey);
  if (v is int) return v;
  return int.tryParse("$v");
}

static Future<Map<String, dynamic>?> getActiveOrderSnapshot() async {
  final box = await Hive.openBox(_prefsBoxName);
  final raw = box.get(_activeOrderKey);
  if (raw is String && raw.isNotEmpty) {
    try {
      final m = jsonDecode(raw);
      if (m is Map) return m.cast<String, dynamic>();
    } catch (_) {}
  }
  return null;
}

static Future<void> clearActiveOrder() async {
  final box = await Hive.openBox(_prefsBoxName);
  await box.delete(_activeOrderIdKey);
  await box.delete(_activeOrderKey);
}

static Future<bool> hasActiveOrder() async =>
    (await getActiveOrderId()) != null;

  static Future<void> setGuestMode(bool value) async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(_isGuestKey, value);
  }
 static const String _meJsonKey = 'me_json';
  static const String _meSavedAtKey = 'me_saved_at_ms';

  static Future<void> saveMeJson(Map<String, dynamic> me) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_meJsonKey, jsonEncode(me));
    await box.put(_meSavedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<Map<String, dynamic>?> getMeJson() async {
    final box = await Hive.openBox(_authBoxName);
    final raw = box.get(_meJsonKey);
    if (raw is! String || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? decoded.cast<String, dynamic>() : null;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getMeSavedAtMs() async {
    final box = await Hive.openBox(_authBoxName);
    final v = box.get(_meSavedAtKey);
    return (v is int) ? v : int.tryParse(v?.toString() ?? "");
  }

  static Future<void> clearMeCache() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_meJsonKey);
    await box.delete(_meSavedAtKey);
  }

  // ✅ اختيارياً: TTL
  static Future<bool> isMeCacheFresh({Duration ttl = const Duration(hours: 6)}) async {
    final savedAt = await getMeSavedAtMs();
    if (savedAt == null) return false;
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(savedAt));
    return age <= ttl;
  }
  // -------------------------------------------------------------
  // 🔹 USER ID MANAGEMENT (Hive)
  // -------------------------------------------------------------
  static const String _userIdKey = 'user_id';

  static Future<void> saveUserId(int id) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_userIdKey, id);
    print('✅ user_id saved: $id');
  }

  static Future<int?> getUserId() async {
    final box = await Hive.openBox(_authBoxName);
    final v = box.get(_userIdKey);
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? "");
  }

  static int? getUserIdSync() {
    try {
      final box = Hive.box(_authBoxName);
      final v = box.get(_userIdKey);
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? "");
    } catch (e) {
      print('⚠️ Hive not ready for getUserIdSync: $e');
      return null;
    }
  }

  static Future<void> removeUserId() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_userIdKey);
    print('🗑️ user_id removed');
  }

  static Future<bool> isGuest() async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(_isGuestKey, defaultValue: false);
  }

  static Future<void> clearGuestMode() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.delete(_isGuestKey);
  }

  static String? getUserRoleSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_roleKey) as String?;
    } catch (e) {
      print('⚠️ Hive not ready for getUserRoleSync: $e');
      return null;
    }
  }

  // -------------------------------------------------------------
  // 🔹 TOKEN MANAGEMENT (Generic)
  // -------------------------------------------------------------
  static Future<void> saveToken(String token) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_tokenKey, token);
    print('✅ Token saved successfully');
  }

  static Future<String?> getToken() async {
    final box = await Hive.openBox(_authBoxName);
    return box.get(_tokenKey);
  }

  static String? getTokenSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_tokenKey);
    } catch (e) {
      print('⚠️ Error getting token synchronously: $e');
      return null;
    }
  }

  static Future<void> removeToken() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_tokenKey);
    print('🗑️ Token removed successfully');
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // -------------------------------------------------------------
  // 🔹 ROLE MANAGEMENT
  // -------------------------------------------------------------
  static Future<void> saveUserRole(String role) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_roleKey, role);
  }

  static Future<String?> getUserRole() async {
    final box = await Hive.openBox(_authBoxName);
    return box.get(_roleKey);
  }

  static Future<void> removeUserRole() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_roleKey);
  }

  // -------------------------------------------------------------
  // 🔹 ZOOM HINT FLAG (Existing)
  // -------------------------------------------------------------
  static Future<bool> isZoomHintDismissed() async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(_zoomHintKey, defaultValue: false) as bool;
  }

  static Future<void> dismissZoomHint() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(_zoomHintKey, true);
  }

  static Future<void> resetZoomHint() async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.delete(_zoomHintKey);
  }

  // -------------------------------------------------------------
  // 🔹 GENERIC FLAGS (Existing)
  // -------------------------------------------------------------
  static Future<void> setFlag(String key, bool value) async {
    final box = await Hive.openBox(_prefsBoxName);
    await box.put(key, value);
  }

  static Future<bool?> getFlag(String key) async {
    final box = await Hive.openBox(_prefsBoxName);
    return box.get(key) as bool?;
  }

  static Future<void> setAcceptCondition(bool accepted) async =>
      setFlag(acceptConditionKey, accepted);

  static Future<bool?> getAcceptCondition() async =>
      getFlag(acceptConditionKey);

  //MAPS STUFF

  static Future<void> saveUserLocation({
    required String lat,
    required String lon,
  }) async {
    final box = await Hive.openBox(_authBoxName);
    await box.put(_latKey, lat);
    await box.put(_lonKey, lon);
    print('✅ Location saved: ($lat, $lon)');
  }

  static Future<Map<String, String?>> getUserLocation() async {
    final box = await Hive.openBox(_authBoxName);
    return {
      "lat": box.get(_latKey) as String?,
      "lon": box.get(_lonKey) as String?,
    };
  }

  static String? getUserLatSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_latKey) as String?;
    } catch (_) {
      return null;
    }
  }

  static String? getUserLonSync() {
    try {
      final box = Hive.box(_authBoxName);
      return box.get(_lonKey) as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeUserLocation() async {
    final box = await Hive.openBox(_authBoxName);
    await box.delete(_latKey);
    await box.delete(_lonKey);
  }
}

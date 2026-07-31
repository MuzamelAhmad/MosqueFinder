import 'dart:convert';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _userIdKey = 'user_id';
  static const String _imamDataKey = 'imam_data';
  static const String _mosquesDataKey = 'mosques_data';

  // ✅ Save User ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // ✅ Get User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // ✅ Remove User ID (Logout)
  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // ═══════════════════════════════════════════
  //             Imam Data Cache
  // ═══════════════════════════════════════════

  static Future<void> cacheImamData(ImamModel imam) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(imam.toJson());
    await prefs.setString(_imamDataKey, jsonString);
  }

  static Future<ImamModel?> getCachedImamData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_imamDataKey);
    if (jsonString == null) return null;
    try {
      return ImamModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════
  //           Nearby Mosques Cache
  // ═══════════════════════════════════════════

  static Future<void> cacheNearbyMosques(List<Map<String, dynamic>> mosques) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(mosques);
    await prefs.setString(_mosquesDataKey, jsonString);
  }

  static Future<List<Map<String, dynamic>>?> getCachedNearbyMosques() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_mosquesDataKey);
    if (jsonString == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════
  //             Tasbeeh Data
  // ═══════════════════════════════════════════
  static const String _tasbihCountKey = 'tasbih_count';
  static const String _tasbihHistoryKey = 'tasbih_history';

  static Future<void> saveTasbihCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tasbihCountKey, count);
  }

  static Future<int> getTasbihCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tasbihCountKey) ?? 0;
  }

  static Future<void> addToTasbihHistory(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_tasbihHistoryKey) ?? [];
    
    final entry = jsonEncode({
      'count': count,
      'date': DateTime.now().toIso8601String(),
    });
    
    history.insert(0, entry); // Add newest first
    // Limit history to last 50 entries
    if (history.length > 50) history.removeLast();
    
    await prefs.setStringList(_tasbihHistoryKey, history);
  }

  static Future<List<Map<String, dynamic>>> getTasbihHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_tasbihHistoryKey) ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> clearTasbihHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasbihHistoryKey);
  }
}

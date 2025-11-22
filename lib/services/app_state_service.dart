import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// App state persistence service
/// Saves and restores last opened note, page, settings, etc.
class AppStateService {
  static const String _keyLastNoteId = 'last_note_id';
  static const String _keyLastPageIndex = 'last_page_index';
  static const String _keyLastSessionTime = 'last_session_time';
  static const String _keyFavoritePens = 'favorite_pens';
  static const String _keyThemeType = 'theme_type';
  static const String _keyCustomFont = 'custom_font';
  static const String _keyWeeklyGoal = 'weekly_goal';

  /// Save last opened note and page
  Future<void> saveLastOpenedNote({
    required String noteId,
    required int pageIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastNoteId, noteId);
    await prefs.setInt(_keyLastPageIndex, pageIndex);
    await prefs.setString(_keyLastSessionTime, DateTime.now().toIso8601String());
  }

  /// Get last opened note info
  Future<Map<String, dynamic>?> getLastOpenedNote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final noteId = prefs.getString(_keyLastNoteId);
      final pageIndex = prefs.getInt(_keyLastPageIndex);
      final sessionTime = prefs.getString(_keyLastSessionTime);

      if (noteId == null) return null;

      return {
        'noteId': noteId,
        'pageIndex': pageIndex ?? 0,
        'sessionTime': sessionTime != null ? DateTime.parse(sessionTime) : null,
      };
    } catch (e) {
      print('Error getting last opened note: $e');
      return null;
    }
  }

  /// Save favorite pens configuration
  Future<void> saveFavoritePens(List<Map<String, dynamic>> pens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavoritePens, jsonEncode(pens));
  }

  /// Get favorite pens configuration
  Future<List<Map<String, dynamic>>?> getFavoritePens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pensJson = prefs.getString(_keyFavoritePens);

      if (pensJson == null) return null;

      final List<dynamic> decoded = jsonDecode(pensJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting favorite pens: $e');
      return null;
    }
  }

  /// Save theme type
  Future<void> saveThemeType(String themeType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeType, themeType);
  }

  /// Get theme type
  Future<String?> getThemeType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeType);
  }

  /// Save custom font
  Future<void> saveCustomFont(String? fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    if (fontFamily != null) {
      await prefs.setString(_keyCustomFont, fontFamily);
    } else {
      await prefs.remove(_keyCustomFont);
    }
  }

  /// Get custom font
  Future<String?> getCustomFont() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomFont);
  }

  /// Save weekly goal
  Future<void> saveWeeklyGoal(Map<String, dynamic> goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWeeklyGoal, jsonEncode(goal));
  }

  /// Get weekly goal
  Future<Map<String, dynamic>?> getWeeklyGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalJson = prefs.getString(_keyWeeklyGoal);

      if (goalJson == null) return null;

      return jsonDecode(goalJson);
    } catch (e) {
      print('Error getting weekly goal: $e');
      return null;
    }
  }

  /// Clear all saved state
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Check if this is first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched') ?? false;

    if (!hasLaunched) {
      await prefs.setBool('has_launched', true);
      return true;
    }

    return false;
  }

  /// Save app launch count (for analytics/features)
  Future<void> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('launch_count') ?? 0;
    await prefs.setInt('launch_count', count + 1);
  }

  /// Get app launch count
  Future<int> getLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('launch_count') ?? 0;
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityService {
  static final UserActivityService instance = UserActivityService._init();
  UserActivityService._init();

  static const _countsKey = 'user_action_counts';
  static const _lastKey = 'last_used_action';

  Future<void> logAction(String actionId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_lastKey, actionId);

    final jsonString = prefs.getString(_countsKey) ?? '{}';
    final Map<String, dynamic> counts = jsonDecode(jsonString);
    counts[actionId] = (counts[actionId] ?? 0) + 1;
    await prefs.setString(_countsKey, jsonEncode(counts));
  }

  Future<List<String>> getMostUsedActions({int count = 4}) async {
    final prefs = await SharedPreferences.getInstance();

    final String? lastUsedAction = prefs.getString(_lastKey);

    final jsonString = prefs.getString(_countsKey) ?? '{}';
    final Map<String, dynamic> counts = jsonDecode(jsonString);

    if (counts.isEmpty) {
      return [];
    }

    var sortedByFrequency = counts.entries.toList();
    sortedByFrequency
        .sort((a, b) => (b.value as int).compareTo(a.value as int));

    final List<String> finalActions = [];

    if (lastUsedAction != null && counts.containsKey(lastUsedAction)) {
      finalActions.add(lastUsedAction);
    }

    for (var entry in sortedByFrequency) {
      if (finalActions.length >= count) {
        break;
      }
      if (!finalActions.contains(entry.key)) {
        finalActions.add(entry.key);
      }
    }

    return finalActions;
  }
}

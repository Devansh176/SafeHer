import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInRepository {
  static const _key = 'safeher_active_checkin';

  Future<void> saveActive({
    required String id,
    required DateTime remindAt,
    required DateTime autoAlertAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'id': id,
      'remindAt': remindAt.toIso8601String(),
      'autoAlertAt': autoAlertAt.toIso8601String(),
    }));
  }

  Future<Map<String, dynamic>?> getActive() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Hook into your existing SOS (location share + contact alerts).
  Future<void> triggerSOSAuto(String reason) async {
    // TODO: integrate your existing SOS dispatch here.
    // e.g., SOSService().sendAutoAlert(reason: reason);
  }
}

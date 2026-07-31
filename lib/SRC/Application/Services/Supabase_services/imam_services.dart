import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// const res = await fetch(
// "https://<project-ref>.supabase.co/functions/v1/summarize-thread",
// {
// method: "POST",
// headers: {
// "Authorization": `Bearer <user-session-access-token>`,
// "Content-Type": "application/json"
// },
// body: JSON.stringify({ thread_id: "<uuid>", max_messages: 50 })
// }
// );
//
// const data = await res.json();
// console.log(data);

class ImamRepository {
  final _supabase = Supabase.instance.client;

  // ✅ Get current logged-in imam email
  String? get _currentEmail => _supabase.auth.currentUser?.email;

  // ═══════════════════════════════════════════
  //             GET — Fetch Imam Data
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>?> getImamDataByUserId(String userId) async {
    final res = await Supabase.instance.client
        .from('ImamData') // <-- your actual table name
        .select()
        .eq('id', userId) // <-- must match your column
        .maybeSingle();

    return res;
  }

  // ✅ Fetch ALL mosques for Muqtadi
  Future<List<Map<String, dynamic>>> getAllMosques() async {
    try {
      final res = await _supabase
          .from('ImamData')
          .select();
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Fetch all mosques error: $e');
      return [];
    }
  }

  // ✅ Check if email exists in ImamData table
  Future<bool> checkEmailExists(String email) async {
    try {
      final res = await _supabase
          .from('ImamData')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      return res != null;
    } catch (e) {
      debugPrint('Check email exists error: $e');
      return false;
    }
  }
  // Future<ImamModel?> getImamData() async {
  //   try {
  //     if (_currentEmail == null) throw Exception('No user logged in');
  //
  //     final response = await _supabase
  //         .from('ImamData')
  //         .select()
  //         .eq('email', _currentEmail!)
  //         .single();
  //
  //     return ImamModel.fromJson(response);
  //   } on PostgrestException catch (e) {
  //     debugPrint('Supabase GET error: ${e.message}');
  //     return null;
  //   } catch (e) {
  //     debugPrint('GET error: $e');
  //     return null;
  //   }
  // }

  // ═══════════════════════════════════════════
  //         GET — Fetch Prayer Times Only
  // ═══════════════════════════════════════════

  Future<PrayerTimesModel?> getPrayerTimes() async {
    try {
      if (_currentEmail == null) throw Exception('No user logged in');

      final response = await _supabase
          .from('ImamData')
          .select('Praytime')
          .eq('email', _currentEmail!)
          .single();

      if (response['Praytime'] == null) return null;

      return PrayerTimesModel.fromJson(response['Praytime']);
    } on PostgrestException catch (e) {
      debugPrint('Supabase GET PrayerTimes error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('GET PrayerTimes error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════
  //       POST — Register New Imam Row
  // ═══════════════════════════════════════════

  Future<bool> postImamData(ImamModel imam) async {
    try {
      await _supabase.from('ImamData').insert(imam.toJson());

      debugPrint('Imam data inserted ✅');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase POST error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('POST error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  //       UPDATE — Update Full Imam Profile
  // ═══════════════════════════════════════════

  Future<bool> updateImamData(ImamModel imam) async {
    try {
      if (_currentEmail == null) throw Exception('No user logged in');

      await _supabase
          .from('ImamData')
          .update(imam.toJson())
          .eq('email', _currentEmail!);

      debugPrint('Imam data updated ✅');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase UPDATE error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('UPDATE error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  //     UPDATE — Update Prayer Times Only
  // ═══════════════════════════════════════════

  Future<bool> updatePrayerTimes(PrayerTimesModel prayerTimes) async {
    try {
      if (_currentEmail == null) throw Exception('No user logged in');

      await _supabase
          .from('ImamData')
          .update({'Praytime': prayerTimes.toJson()})
          .eq('email', _currentEmail!);

      debugPrint('Prayer times updated ✅');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase UPDATE PrayerTimes error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('UPDATE PrayerTimes error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  //     UPDATE — Update Single Prayer Time
  // ═══════════════════════════════════════════

  Future<bool> updateSinglePrayerTime({
    required String prayerKey, // 'fajr', 'dhuhr', etc.
    required String newTime, // '5:50'
  }) async {
    try {
      if (_currentEmail == null) throw Exception('No user logged in');

      // 1. Fetch current prayer times first
      final current = await getPrayerTimes();
      if (current == null) return false;

      // 2. Update only the changed one using copyWith
      final updated = current.copyWith(
        fajr: prayerKey == 'fajr' ? newTime : null,
        dhuhr: prayerKey == 'dhuhr' ? newTime : null,
        jumma: prayerKey == 'jumma' ? newTime : null,
        asr: prayerKey == 'asr' ? newTime : null,
        maghrib: prayerKey == 'maghrib' ? newTime : null,
        isha: prayerKey == 'isha' ? newTime : null,
      );

      // 3. Save back to Supabase
      return await updatePrayerTimes(updated);
    } catch (e) {
      debugPrint('UPDATE single prayer time error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  //        UPDATE — Update Imam Location
  // ═══════════════════════════════════════════

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (_currentEmail == null) throw Exception('No user logged in');

      await _supabase
          .from('ImamData')
          .update({'latitude': latitude, 'longitude': longitude})
          .eq('email', _currentEmail!);

      debugPrint('Location updated ✅');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Supabase UPDATE Location error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('UPDATE Location error: $e');
      return false;
    }
  }
}

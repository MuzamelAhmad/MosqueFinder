import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosque_finder/SRC/Application/Services/Supabase_services/imam_services.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'imam_state.dart';

class ImamCubit extends Cubit<ImamState> {
  final ImamRepository _repo = ImamRepository();

  ImamCubit() : super(ImamInitial());

  // ═══════════════════════════════════════════
  //            Pick Location
  // ═══════════════════════════════════════════
  Future<void> pickLocation() async {
    emit(ImamLocationLoading());

    try {
      // 1. Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(ImamLocationError('Location permission denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          ImamLocationError(
            'Location permanently denied. Enable from settings.',
          ),
        );
        return;
      }

      // 2. Get position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 3. Reverse geocode
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final Placemark place = placemarks.first;
      final String city =
          place.locality ?? place.administrativeArea ?? 'Unknown';

      emit(
        ImamLocationLoaded(
          latitude: position.latitude,
          longitude: position.longitude,
          city: city,
        ),
      );
    } catch (e) {
      emit(ImamLocationError('Failed to get location: $e'));
    }
  }

  // ═══════════════════════════════════════════
  //              Signup
  // ═══════════════════════════════════════════
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String mosqueName,
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    emit(ImamLoading());

    try {
      // 1) Supabase Auth signup
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      print('immmammmmm $user');
      if (user == null) {
        emit(ImamSignupError('Signup failed. Try again.'));
        return;
      }

      final userId = user.id;

      print("user id ------------------$userId");

      // 2) Insert ImamData for THIS userId
      final imam = ImamModel(
        id: userId, // or omit if your DB uses serial/identity
        imamName: fullName,
        mosqueName: mosqueName,
        city: city,
        latitude: latitude,
        longitude: longitude,
        email: email,

        // ✅ remove `password` from your model entirely
        prayTime: PrayerTimesModel(
          fajr: '--:--',
          dhuhr: '--:--',
          jumma: '--:--',
          asr: '--:--',
          maghrib: '--:--',
          isha: '--:--',
        ),
      );

      final success = await _repo.postImamData(imam);
      if (!success) {
        emit(ImamSignupError('Failed to save data. Try again.'));
        return;
      }

      emit(ImamSignupSuccess(userId));
    } on AuthException catch (e) {
      // Handle rate limit specifically
      if (e.message.contains('after') && e.message.contains('seconds')) {
        emit(ImamSignupError('Please wait a moment before trying again.'));
      } else {
        emit(ImamSignupError(e.message));
      }
    } catch (e) {
      emit(ImamSignupError('Error: $e'));
    }
  }

  // ═══════════════════════════════════════════
  //           Fetch Imam Data
  // ════════════════════════════════════
  Future<void> getImamData() async {
    emit(ImamLoading());

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(ImamError('User not logged in'));
        return;
      }

      final imam = await _repo.getImamDataByUserId(user.id);
      print('Raw response: $imam');
      if (imam != null) {
        emit(ImamLoaded(ImamModel.fromJson(imam)));
      } else {
        emit(ImamError('No data found'));
      }
    } catch (e) {
      emit(ImamError('Fetch error: $e'));
    }
  }

  // ═══════════════════════════════════════════
  //         Fetch Prayer Times
  // ═══════════════════════════════════════════
  Future<void> getPrayerTimes() async {
    emit(ImamLoading());
    try {
      final times = await _repo.getPrayerTimes();
      if (times != null) {
        emit(PrayerTimesLoaded(times));
      } else {
        emit(ImamError('No prayer times found'));
      }
    } catch (e) {
      emit(ImamError('Fetch prayer times error: $e'));
    }
  }

  // ═══════════════════════════════════════════
  //       Update Single Prayer Time
  // ═══════════════════════════════════════════
  Future<void> updateSinglePrayerTime({
    required String prayerKey,
    required String newTime,
  }) async {
    emit(ImamLoading());
    try {
      final success = await _repo.updateSinglePrayerTime(
        prayerKey: prayerKey,
        newTime: newTime,
      );

      if (success) {
        emit(SinglePrayerTimeUpdateSuccess());
        // Refresh prayer times after update
        await getPrayerTimes();
      } else {
        emit(SinglePrayerTimeUpdateError('Failed to update prayer time'));
      }
    } catch (e) {
      emit(SinglePrayerTimeUpdateError('Update error: $e'));
    }
  }

  // ═══════════════════════════════════════════
  //         Update Full Prayer Times
  // ═══════════════════════════════════════════
  Future<void> updatePrayerTimes(PrayerTimesModel prayerTimes) async {
    emit(ImamLoading());
    try {
      final success = await _repo.updatePrayerTimes(prayerTimes);

      if (success) {
        emit(PrayerTimesUpdateSuccess());
        await getPrayerTimes();
      } else {
        emit(PrayerTimesUpdateError('Failed to update prayer times'));
      }
    } catch (e) {
      emit(PrayerTimesUpdateError('Update error: $e'));
    }
  }

  // ═══════════════════════════════════════════
  //                 Login
  // ═══════════════════════════════════════════
  Future<void> login({required String email, required String password}) async {
    emit(ImamLoading());

    try {
      // 1. Supabase Auth login
      final authResponse = Supabase.instance.client;
      final session = await authResponse.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (session.user == null) {
        emit(ImamLoginError('Login failed. Check your credentials.'));
        print("login data -----------${session.user}");
        return;
      }

      final String userId = session.user!.id;

      // 2. Verify imam exists in ImamData table
      final imam = await _repo.getImamDataByUserId(userId);

      if (imam == null) {
        emit(ImamLoginError('Imam account not found.'));
        return;
      }
      print(imam);
      // print("login data -----------${session.user}");

      emit(ImamLoginSuccess(userId));
    } on AuthException catch (e) {
      print("login data -----------${e.message}");
      emit(ImamLoginError(e.message));
    } catch (e) {
      // print("login data -----------$e");
      emit(ImamLoginError('Login error: $e'));
    }
  }
}

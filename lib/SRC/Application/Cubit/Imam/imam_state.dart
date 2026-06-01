part of 'imam_cubit.dart';

abstract class ImamState {}

// ── Initial ──────────────────────────────────────
class ImamInitial extends ImamState {}

// ── Loading ──────────────────────────────────────
class ImamLoading extends ImamState {}

// ── Location ─────────────────────────────────────
class ImamLocationLoading extends ImamState {}

class ImamLocationLoaded extends ImamState {
  final double latitude;
  final double longitude;
  final String city;

  ImamLocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.city,
  });
}

class ImamLocationError extends ImamState {
  final String message;
  ImamLocationError(this.message);
}

// ── Signup ────────────────────────────────────────
class ImamSignupSuccess extends ImamState {
  final String userId;
  ImamSignupSuccess(this.userId);
}

class ImamSignupError extends ImamState {
  final String message;
  ImamSignupError(this.message);
}
// ── Login ─────────────────────────────────────

class ImamLoginSuccess extends ImamState {
  final String userId;
  ImamLoginSuccess(this.userId);
}

class ImamLoginError extends ImamState {
  final String message;
  ImamLoginError(this.message);
}

// ── Fetch ─────────────────────────────────────────
class ImamLoaded extends ImamState {
  final ImamModel imam;
  ImamLoaded(this.imam);
}

class ImamError extends ImamState {
  final String message;
  ImamError(this.message);
}

// ── PrayerTimes ───────────────────────────────────
class PrayerTimesLoaded extends ImamState {
  final PrayerTimesModel prayerTimes;
  PrayerTimesLoaded(this.prayerTimes);
}

class PrayerTimesUpdateSuccess extends ImamState {}

class PrayerTimesUpdateError extends ImamState {
  final String message;
  PrayerTimesUpdateError(this.message);
}

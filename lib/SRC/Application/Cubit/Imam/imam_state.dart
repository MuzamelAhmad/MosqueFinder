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

// ── Single Prayer Time Update ─────────────────
class SinglePrayerTimeUpdateSuccess extends ImamState {}

class SinglePrayerTimeUpdateError extends ImamState {
  final String message;
  SinglePrayerTimeUpdateError(this.message);
}

// ── Profile Update ───────────────────────────
class ImamProfileUpdateSuccess extends ImamState {}

class ImamProfileUpdateError extends ImamState {
  final String message;
  ImamProfileUpdateError(this.message);
}

// ── Forget Password ──────────────────────────
class ImamForgetPasswordSuccess extends ImamState {}

class ImamForgetPasswordError extends ImamState {
  final String message;
  ImamForgetPasswordError(this.message);
}

// ── Password Update ──────────────────────────
class ImamPasswordUpdateSuccess extends ImamState {}

class ImamPasswordUpdateError extends ImamState {
  final String message;
  ImamPasswordUpdateError(this.message);
}

// ── Offline ──────────────────────────────────
class ImamNoInternetError extends ImamState {
  final String message;
  ImamNoInternetError(this.message);
}

// ── Social Login ─────────────────────────────
class ImamSocialLoginIncomplete extends ImamState {
  final String userId;
  final String email;
  final String name;

  ImamSocialLoginIncomplete({
    required this.userId,
    required this.email,
    required this.name,
  });
}

class ImamSocialLoginError extends ImamState {
  final String message;
  ImamSocialLoginError(this.message);
}

// ── Email Verification ──────────────────────
class ImamEmailUnverified extends ImamState {
  final String email;
  ImamEmailUnverified(this.email);
}

class ImamEmailResendSuccess extends ImamState {}

class ImamEmailResendError extends ImamState {
  final String message;
  ImamEmailResendError(this.message);
}

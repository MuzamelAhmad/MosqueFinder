part of 'muqtadi_cubit.dart';

abstract class MuqtadiState {}

class MuqtadiInitial extends MuqtadiState {}

class MuqtadiLoading extends MuqtadiState {}

class MuqtadiLoaded extends MuqtadiState {
  final List<Map<String, dynamic>> mosques;
  final double userLat;
  final double userLng;

  MuqtadiLoaded({
    required this.mosques,
    required this.userLat,
    required this.userLng,
  });
}

class MuqtadiError extends MuqtadiState {
  final String message;
  MuqtadiError(this.message);
}

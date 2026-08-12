import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosque_finder/SRC/Application/Services/Supabase_services/imam_services.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';
import 'package:mosque_finder/SRC/Application/Utils/connectivity_helper.dart';
import 'dart:async';

part 'muqtadi_state.dart';

class MuqtadiCubit extends Cubit<MuqtadiState> {
  final ImamRepository _repo = ImamRepository();
  Timer? _refreshTimer;

  MuqtadiCubit() : super(MuqtadiInitial()) {
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await ConnectivityHelper.hasInternet()) {
        fetchNearbyMosques(showLoading: false);
      }
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> fetchNearbyMosques({bool showLoading = true}) async {
    // ✅ 1. IMMEDIATE CACHE LOAD
    final cachedMosques = await SharedPrefsService.getCachedNearbyMosques();
    if (cachedMosques != null && cachedMosques.isNotEmpty) {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        final processed = _processAndFilter(cachedMosques, lastPos);
        emit(MuqtadiLoaded(
          mosques: processed,
          userLat: lastPos.latitude,
          userLng: lastPos.longitude,
        ));
        showLoading = false; 
      }
    }

    if (showLoading) emit(MuqtadiLoading());

    try {
      // 2. Optimized Location Strategy
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (state is! MuqtadiLoaded) {
          emit(MuqtadiError('Location services are disabled. Please turn them on in settings.'));
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (state is! MuqtadiLoaded) {
            emit(MuqtadiError('Location permission is required to find mosques near you.'));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (state is! MuqtadiLoaded) {
          emit(MuqtadiError('Location permissions are permanently denied. Please enable them in settings.'));
        }
        return;
      }

      // Get precise position with a 5-second timeout
      Position? currentPos;
      try {
        currentPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        currentPos = await Geolocator.getLastKnownPosition();
      }

      if (currentPos == null) {
        if (state is! MuqtadiLoaded) emit(MuqtadiError('Could not determine your location.'));
        return;
      }

      // 3. Background Network Fetch
      final isOnline = await ConnectivityHelper.hasInternet();
      List<Map<String, dynamic>> mosquesToProcess = [];

      if (isOnline) {
        final freshMosques = await _repo.getAllMosques();
        if (freshMosques.isNotEmpty) {
          await SharedPrefsService.cacheNearbyMosques(freshMosques);
          mosquesToProcess = freshMosques;
        } else {
          mosquesToProcess = cachedMosques ?? [];
        }
      } else {
        if (cachedMosques != null) {
          mosquesToProcess = cachedMosques;
        } else {
          emit(MuqtadiError('No internet and no cached data.'));
          return;
        }
      }

      // 4. State Update with Precise Location
      final finalProcessed = _processAndFilter(mosquesToProcess, currentPos);

      emit(MuqtadiLoaded(
        mosques: finalProcessed,
        userLat: currentPos.latitude,
        userLng: currentPos.longitude,
      ));

    } catch (e) {
      if (state is! MuqtadiLoaded) {
        emit(MuqtadiError('Something went wrong. Please try refreshing.'));
      }
    }
  }

  List<Map<String, dynamic>> _processAndFilter(List<Map<String, dynamic>> mosques, Position pos) {
    final List<Map<String, dynamic>> filtered = [];

    for (var m in mosques) {
      // Create a fresh map to avoid modifying the original cached data in-place
      final mosque = Map<String, dynamic>.from(m);
      
      final double lat = (mosque['latitude'] as num).toDouble();
      final double lng = (mosque['longitude'] as num).toDouble();

      final double distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        lat,
        lng,
      );

      // ✅ 1 km radius filter
      if (distance <= 1000) {
        mosque['distance_meters'] = distance;
        filtered.add(mosque);
      }
    }

    // Sort by proximity: closest first
    filtered.sort((a, b) =>
        (a['distance_meters'] as double).compareTo(b['distance_meters'] as double));

    return filtered;
  }
}

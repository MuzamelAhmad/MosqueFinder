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
        fetchNearbyMosques();
      }
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> fetchNearbyMosques() async {
    emit(MuqtadiLoading());

    try {
      // 1. Get user location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(MuqtadiError('Location services are disabled.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(MuqtadiError('Location permission denied. Please enable it in settings.'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(MuqtadiError('Location permissions are permanently denied. Please enable them in settings.'));
        return;
      }

      final Position userPos = await Geolocator.getCurrentPosition();
      print('MUQTADI: User Position -> Lat: ${userPos.latitude}, Lng: ${userPos.longitude}');

      // Check internet first
      final isOnline = await ConnectivityHelper.hasInternet();
      List<Map<String, dynamic>> allMosques = [];

      if (!isOnline) {
        final cached = await SharedPrefsService.getCachedNearbyMosques();
        if (cached != null) {
          allMosques = cached;
          print('MUQTADI: Using cached data (Offline)');
        } else {
          emit(MuqtadiError('No internet and no cached data.'));
          return;
        }
      } else {
        // 2. Fetch all mosques from Supabase
        allMosques = await _repo.getAllMosques();
        print('MUQTADI: Total mosques in DB: ${allMosques.length}');
        // ✅ Cache for next time
        await SharedPrefsService.cacheNearbyMosques(allMosques);
      }

      // 3. Filter and Calculate (1 km radius)
      final List<Map<String, dynamic>> filteredMosques = [];

      for (var mosque in allMosques) {
        final double lat = (mosque['latitude'] as num).toDouble();
        final double lng = (mosque['longitude'] as num).toDouble();

        final double distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          lat,
          lng,
        );

        print('MUQTADI: Mosque "${mosque['mosque name']}" is ${distance.toStringAsFixed(2)}m away');

        // ✅ User requested: 1 km radius
        if (distance <= 1000) {
          // Add distance to the map for UI display
          mosque['distance_meters'] = distance;
          filteredMosques.add(mosque);
        }
      }

      print('MUQTADI: Found ${filteredMosques.length} mosques within 1km');

      // 4. Sort by proximity
      filteredMosques.sort((a, b) =>
          (a['distance_meters'] as double).compareTo(b['distance_meters'] as double));

      emit(MuqtadiLoaded(
        mosques: filteredMosques,
        userLat: userPos.latitude,
        userLng: userPos.longitude,
      ));
    } catch (e) {
      String userFriendlyMessage = 'Something went wrong. Please refresh.';
      if (e.toString().contains('Location services')) {
        userFriendlyMessage = 'Location services are disabled. Please turn them on in settings.';
      } else if (e.toString().contains('permission denied')) {
        userFriendlyMessage = 'Location permission is required to find mosques near you.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        userFriendlyMessage = 'Unable to connect to the internet. Showing cached data.';
      }
      
      emit(MuqtadiError(userFriendlyMessage));
    }
  }
}

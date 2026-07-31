import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosque_finder/SRC/Application/Services/Supabase_services/imam_services.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';
import 'package:mosque_finder/SRC/Application/Utils/connectivity_helper.dart';

part 'muqtadi_state.dart';

class MuqtadiCubit extends Cubit<MuqtadiState> {
  final ImamRepository _repo = ImamRepository();

  MuqtadiCubit() : super(MuqtadiInitial());

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
          emit(MuqtadiError('Location permission denied.'));
          return;
        }
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
      emit(MuqtadiError('Failed to load nearby mosques: $e'));
    }
  }
}

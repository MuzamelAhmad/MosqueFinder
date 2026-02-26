import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LiveCityWidget extends StatefulWidget {
  const LiveCityWidget({super.key});

  @override
  State<LiveCityWidget> createState() => _LiveCityWidgetState();
}

class _LiveCityWidgetState extends State<LiveCityWidget> {
  String _city = "Detecting...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentCity();
  }

  Future<void> _getCurrentCity() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _city = "Location services disabled";
        _isLoading = false;
        AppSettings.openAppSettings(type: AppSettingsType.location);
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _city = "Location permission denied";
          _isLoading = false;
          AppSettings.openAppSettings(type: AppSettingsType.location);
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _city = "Permission permanently denied";
        _isLoading = false;
        AppSettings.openAppSettings(type: AppSettingsType.location);
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        // desiredAccuracy: LocationAccuracy.medium, // balanced battery/accuracy
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 100,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city =
            place.locality ??
            place.subLocality ??
            place.administrativeArea ??
            "Unknown";
        setState(() {
          _city = city;
          _isLoading = false;
        });
      } else {
        setState(() {
          _city = "City not found";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _city = "Error: ${e.toString().split('\n')[0]}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          )
        else
          const Icon(Icons.location_city, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          "City: $_city",
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

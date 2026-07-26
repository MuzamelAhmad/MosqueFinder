class ImamModel {
  final String id;
  final String imamName;
  final String mosqueName;
  final String city;
  final double latitude;
  final double longitude;
  final String email;
  final PrayerTimesModel? prayTime;

  ImamModel({
    required this.id,
    required this.imamName,
    required this.mosqueName,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.email,
    this.prayTime,
  });

  // ✅ From Supabase JSON
  factory ImamModel.fromJson(Map<String, dynamic> json) {
    return ImamModel(
      id: json['id'] as String,
      imamName: json['Imam name'] as String,
      mosqueName: json['mosque name'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      email: json['email'] as String,
      prayTime: json['Praytime'] != null
          ? PrayerTimesModel.fromJson(json['Praytime'])
          : null,
    );
  }

  // ✅ To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Imam name': imamName,
      'mosque name': mosqueName,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'email': email,
      'Praytime': prayTime?.toJson(),
    };
  }

  // ✅ CopyWith — useful for updating single fields
  ImamModel copyWith({
    String? id,
    String? imamName,
    String? mosqueName,
    String? city,
    double? latitude,
    double? longitude,
    String? email,
    String? password,
    PrayerTimesModel? prayTime,
  }) {
    return ImamModel(
      id: id ?? this.id,
      imamName: imamName ?? this.imamName,
      mosqueName: mosqueName ?? this.mosqueName,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      email: email ?? this.email,
      prayTime: prayTime ?? this.prayTime,
    );
  }
}

// ✅ Separate model for Praytime jsonb column
class PrayerTimesModel {
  final String fajr;
  final String dhuhr;
  final String jumma;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimesModel({
    required this.fajr,
    required this.dhuhr,
    required this.jumma,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      fajr: json['fajr'] ?? '--:--',
      dhuhr: json['dhuhr'] ?? '--:--',
      jumma: json['jumma'] ?? '--:--',
      asr: json['asr'] ?? '--:--',
      maghrib: json['maghrib'] ?? '--:--',
      isha: json['isha'] ?? '--:--',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'dhuhr': dhuhr,
      'jumma': jumma,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  // ✅ CopyWith for updating single prayer time
  PrayerTimesModel copyWith({
    String? fajr,
    String? dhuhr,
    String? jumma,
    String? asr,
    String? maghrib,
    String? isha,
  }) {
    return PrayerTimesModel(
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      jumma: jumma ?? this.jumma,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }
}

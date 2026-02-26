import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriProvider with ChangeNotifier {
  String _hijriDate = "fetching......";

  String get hijriDate => _hijriDate;

  Future<void> fetchHijriDate() async {
    final today = HijriCalendar.now();
    final formattedDate = today.toFormat("dd MMMM yyyy");
    _hijriDate = formattedDate;
    notifyListeners();
  }
}

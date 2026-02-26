import 'dart:async';

import 'package:flutter/material.dart';

class LiveClock extends StatefulWidget {
  final TextStyle? style;

  const LiveClock({super.key, this.style});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  String _time = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateTime();
    });
  }

  // void _update() {
  //   final now = DateTime.now();
  //   setState(() {
  //     _time =
  //         "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  //     // Add :${now.second.toString().padLeft(2, '0')} if you want seconds
  //   });
  // }
  void _updateTime() {
    final now = DateTime.now();

    int hour = now.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour
    hour = hour % 12;
    if (hour == 0) hour = 12; // 00:xx → 12:xx

    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final secondStr = now.second.toString().padLeft(2, '0'); // optional

    setState(() {
      _time = '$hourStr:$minuteStr:$secondStr $period';
      // Or with seconds: '$hourStr:$minuteStr:$secondStr $period'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_time, style: widget.style);
  }
}

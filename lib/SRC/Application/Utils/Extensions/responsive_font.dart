import 'package:flutter/material.dart';

extension ResponsiveText on num {
  /// Scales the number based on the device's screen width.
  /// Standard design width is often 375 (iPhone X style).
  double sp(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the scale factor
    // 375 is the layout width from your design tool (Figma/Adobe XD)
    double scaleFactor = screenWidth / 375;

    return this * scaleFactor;
  }
}

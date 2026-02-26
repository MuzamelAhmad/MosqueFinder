import 'package:flutter/widgets.dart';

// Define an extension on the Widget class
extension WidgetPaddingExtensions on Widget {
  /// Applies uniform padding to the widget.
  Padding paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  /// Applies symmetric padding (horizontal and vertical) to the widget.
  Padding paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Applies custom padding to specific sides of the widget.
  Padding paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  // Add more specific methods like paddingTop, paddingBottom, etc. as needed...
}

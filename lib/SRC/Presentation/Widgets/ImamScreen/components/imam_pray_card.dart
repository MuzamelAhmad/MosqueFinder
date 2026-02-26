import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImamPrayCard extends StatelessWidget {
  final Widget widget;
  const ImamPrayCard({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha((255 * 0.12).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withAlpha((255 * 0.15).toInt()),
        ),
      ),
      child: widget,
    );
  }
}

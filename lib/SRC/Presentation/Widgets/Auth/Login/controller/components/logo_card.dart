import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoCard extends StatelessWidget {
  final String path;
  final void Function()? OnTap;
  const LogoCard({super.key, required this.path, this.OnTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: OnTap,
      child: Container(
        height: 40.h,
        width: 60.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary.withAlpha((255 * 0.2).toInt()),
          borderRadius: BorderRadius.circular(10.r),
          // image: DecorationImage(image: AssetImage(path), fit: BoxFit.contain),
        ),
        child: Center(
          child: Image.asset(path, height: 30.h, width: 30.w),
        ),
      ),
    );
  }
}

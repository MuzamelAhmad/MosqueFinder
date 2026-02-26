import 'package:flutter/material.dart';

class CommonIconData extends StatelessWidget {
  final IconData icanData;
  final Color? bgColor;
  final Color? iconColor;
  final void Function()? onTap;

  const CommonIconData({
    super.key,
    required this.icanData,
    this.bgColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor ?? theme.colorScheme.secondary,
        ),
        child: Center(
          child: Icon(
            icanData,
            color: iconColor ?? theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

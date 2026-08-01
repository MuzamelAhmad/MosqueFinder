import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';

class ProfessionalDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color? iconColor;
  final List<Widget>? actions;

  const ProfessionalDialog({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.iconColor,
    this.actions,
  });

  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
    List<Widget>? actions,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfessionalDialog(
        title: title,
        content: content,
        icon: icon,
        iconColor: iconColor,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.shade900,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white12, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Center(
                child: Icon(icon, color: iconColor ?? Colors.white, size: 48.r),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions ?? [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

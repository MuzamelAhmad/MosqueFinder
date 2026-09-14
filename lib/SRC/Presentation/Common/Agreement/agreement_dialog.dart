import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementDialog extends StatefulWidget {
  const AgreementDialog({super.key});

  static Future<void> show(BuildContext context) async {
    final bool accepted = await SharedPrefsService.hasAcceptedTerms();
    if (!accepted) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AgreementDialog(),
        );
      }
    }
  }

  @override
  State<AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<AgreementDialog> {
  ValueNotifier<bool> _showMore = ValueNotifier(false);

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://drive.google.com/file/d/1wPkTwBJ_kfK17oOCTYx3hiXOztN0ABqN/view?usp=sharing');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.shade900,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: Colors.white12, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.5*255).toInt()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Icon and Motto
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white10, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                children: [
                  Icon(Icons.people_alt_rounded, color: Colors.white, size: 50.r),
                  SizedBox(height: 16.h),
                  Text(
                    'Salah 360',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '“Punctuality in Prayer, Unity in Jama’at”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.95*255).toInt()),
                      fontSize: 15.sp,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ValueListenableBuilder(
                  valueListenable: _showMore,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to our community. To ensure a seamless experience for every Muqtadi and Imam, we need your agreement on:',
                          style: TextStyle(color: Colors.white.withAlpha((0.9*255).toInt()), fontSize: 14.sp),
                        ),
                        Text('By continuing, you agree to our ', style: TextStyle(color: Colors.white.withAlpha((0.9*255).toInt()), fontSize: 14.sp),
                        ),
                        GestureDetector(
                          onTap: _launchPrivacyPolicy, // Uses the same launcher method above
                          child:  Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              decoration: TextDecoration.underline,

                                decorationColor: Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        _buildPermissionItem(
                          Icons.location_on_rounded,
                          'Live Proximity',
                          'Calculates distances to show you the closest mosques in a 1-5 min walk.',
                        ),
                        _buildPermissionItem(
                          Icons.notifications_active_rounded,
                          'Precise Alarms',
                          'Sends high-priority reminders 5 minutes before every Jama\'at.',
                        ),

                        if (_showMore.value) ...[
                          SizedBox(height: 10.h),
                          _buildPermissionItem(
                            Icons.verified_user_rounded,
                            'Community Impact',
                            'By sharing accurate timings, Imams help the community maintain punctuality and unity in worship.',
                          ),
                          _buildPermissionItem(
                            Icons.data_usage_rounded,
                            'Secure Caching',
                            'We save data locally so you can check prayer times even without internet.',
                          ),
                        ],

                        TextButton(
                          onPressed: () =>_showMore.value = !_showMore.value,
                          child: Text(
                            _showMore.value ? 'Show Less' : 'Show More Details...',
                            style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
            ),

            // Actions
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text('Cancel', style: theme.textTheme.titleSmall?.copyWith(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await SharedPrefsService.acceptTerms();
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: theme.colorScheme.primary.withAlpha((0.5*255).toInt()),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text('I Agree', style:theme.textTheme.titleSmall?.copyWith(color: Colors.white) ),
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

  Widget _buildPermissionItem(IconData icon, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.1*255).toInt()),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.white, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: TextStyle(color: Colors.white60, fontSize: 12.sp, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

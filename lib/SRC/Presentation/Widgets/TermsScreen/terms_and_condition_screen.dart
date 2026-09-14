import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Terms & Conditions',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.bgColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  '1. Our Mission',
                  'Salah 360 is dedicated to connecting the Muslim community with their local mosques. Our mission is to ensure every Muqtadi reaches the Mosque on time for Jama\'at through live timing updates and reliable reminders.',
                ),
                _buildSection(
                  context,
                  '2. Core Functionality',
                  '• Real-time prayer timing updates provided by verified Imams.\n'
                  '• Accurate proximity-based mosque search.\n'
                  '• High-priority prayer alerts scheduled locally on your device.',
                ),
                _buildSection(
                  context,
                  '3. Data Privacy',
                  'We respect your privacy. Your location is processed locally to calculate distances and is only shared with our servers when searching for mosques. Profile data for Imams is stored securely to facilitate community coordination.',
                ),
                _buildSection(
                  context,
                  '4. Permissions',
                  'To function effectively, Salah 360 requires:\n'
                  '• Location: To identify the closest mosques to you.\n'
                  '• Alarms & Reminders: To provide precise prayer alerts.\n'
                  '• Storage: To cache data for offline accessibility.',
                ),
                _buildSection(
                  context,
                  '5. Community Impact',
                  'By using Salah 360, you contribute to a more punctual and connected community, strengthening the bonds of brotherhood and ensuring collective worship is never missed.',
                ),
                SizedBox(height: 30.h),
                Center(
                  child: Text(
                    'Version 1.0.0 • August 2026',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha((0.8*255).toInt()),
              fontSize: 15.sp,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

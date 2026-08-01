import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Data/repositories/ImamModel/imam_model.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamProfile/imam_profile.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Seclection_Screen/selection_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/NotificationScreen/notification_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/TermsScreen/terms_and_condition_screen.dart';

class CustomizeDrawerScreen extends StatelessWidget {
  final ImamModel imam;
  const CustomizeDrawerScreen({super.key, required this.imam});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle? styleMedium = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Drawer(
      backgroundColor: Colors.indigo.shade900,
      elevation: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header of the Drawer
            Material(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImamProfile(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.bgColors,
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        imam.imamName,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        imam.email,
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ).paddingAll(10),
                ),
              ),
            ),

            /// Header Menu items
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.bgColors,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Profile', style: styleMedium),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImamProfile(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.policy,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Terms & Condition', style: styleMedium),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsAndConditionScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.black45),
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Notifications', style: styleMedium),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.black45),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      'Logout',
                      style: styleMedium?.copyWith(color: Colors.redAccent),
                    ),
                    onTap: () async {
                      // ✅ Clear persisted session
                      await SharedPrefsService.removeUserId();

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectionScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
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

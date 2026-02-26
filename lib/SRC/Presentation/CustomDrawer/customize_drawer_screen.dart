import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';

class CustomizeDrawerScreen extends StatelessWidget {
  const CustomizeDrawerScreen({super.key});

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
                  /// Close Navigation drawer before
                  // Navigator.pop(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile()),);
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
                    children: const [
                      CircleAvatar(
                        radius: 52,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHNtaWx5JTIwZmFjZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
                          // 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8c21pbHklMjBmYWNlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60'
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sophia',
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      ),
                      Text(
                        '@sophia.com',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
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
                      Icons.home_outlined,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Home', style: styleMedium),
                    onTap: () {
                      /// Close Navigation drawer before
                      // Navigator.pop(context);
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()),);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.favorite_border,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Favourites', style: styleMedium),
                    onTap: () {
                      /// Close Navigation drawer before
                      // Navigator.pop(context);
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => FavouriteScreen()),);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.workspaces,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Workflow', style: styleMedium),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.update,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Updates', style: styleMedium),
                    onTap: () {},
                  ),
                  const Divider(color: Colors.black45),
                  ListTile(
                    leading: Icon(
                      Icons.account_tree_outlined,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Plugins', style: styleMedium),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: theme.colorScheme.onPrimary,
                    ),
                    title: Text('Notifications', style: styleMedium),
                    onTap: () {},
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

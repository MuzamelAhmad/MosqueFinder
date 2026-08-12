import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/App_Paths/paths.dart'
    show AppPath;
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/Login/controller/components/logo_card.dart';

class SocialAccountCard extends StatelessWidget {
  final String title1;
  final String Title2;
  final void Function()? OnTap;
  const SocialAccountCard({
    super.key,
    required this.title1,
    required this.Title2,
    this.OnTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title1,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: OnTap,
              child: Text(
                Title2,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Divider(color: theme.colorScheme.onPrimary),
        Text(
          'Sign Up with',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => context.read<ImamCubit>().signInWithGoogle(),
              child: LogoCard(path: AppPath.google),
            ),
            SizedBox(width: 10.w),
            InkWell(
              onTap: () => context.read<ImamCubit>().signInWithFacebook(),
              child: LogoCard(path: AppPath.facebook),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../Application/Utils/Extensions/padding.dart';
import '../../../../Data/Resources/App_Strings/app_titles.dart';
import '../../../Common/common_Icon.dart';

class WierdCard extends StatefulWidget {
  const WierdCard({super.key});

  @override
  State<WierdCard> createState() => _WierdCardState();
}

class _WierdCardState extends State<WierdCard> {
  final List<Map<String, String>> _wierdList = [
    {'Title': AppTitles.wierdArbi1, 'wierd': AppTitles.wierd1},
    {'Title': AppTitles.wierdArbi2, 'wierd': AppTitles.wierd2},
    {'Title': AppTitles.wierdArbi3, 'wierd': AppTitles.wierd3},
  ];

  int _currentIndex = 0;

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _goToNext() {
    if (_currentIndex < _wierdList.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentItem = _wierdList[_currentIndex];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left arrow (previous)
        CommonIconData(
          onTap: _goToPrevious,
          bgColor: Colors.black12,
          icanData: Icons.arrow_back_ios_rounded,
          iconColor: _currentIndex > 0
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimary.withAlpha((255 * 0.3).toInt()),
        ),

        // Center content with only text animating
        SizedBox(
          height: 120, // give it some fixed space
          width: 180,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
                // You can also try:
                // ScaleTransition(scale: animation, child: child);
                // SlideTransition(
                //   position: Tween<Offset>(
                //     begin: const Offset(0.3, 0),
                //     end: Offset.zero,
                //   ).animate(animation),
                //   child: child,
                // );
              },
              child: Column(
                key: ValueKey<int>(
                  _currentIndex,
                ), // ← important for AnimatedSwitcher
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentItem['Title'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentItem['wierd'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ).paddingAll(16),
            ),
          ),
        ),

        // Right arrow (next)
        CommonIconData(
          onTap: _goToNext,
          icanData: Icons.arrow_forward_ios_rounded,
          bgColor: Colors.black12,
          iconColor: _currentIndex < _wierdList.length - 1
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimary.withAlpha((255 * 0.3).toInt()),
        ),
      ],
    );
  }
}

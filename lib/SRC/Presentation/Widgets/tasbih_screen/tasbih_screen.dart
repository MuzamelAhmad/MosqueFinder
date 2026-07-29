import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/App_Strings/app_titles.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';

import '../../../Application/Utils/Extensions/padding.dart';
import '../../Common/common_Icon.dart';
import 'components/wierd_card.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  final ValueNotifier<int> _counter = ValueNotifier(0);

  void _incrementCounter() {
    _counter.value++;
  }

  void restCounter() {
    if (_counter.value != 0) {
      _counter.value = 0;
    } else {
      CustomSnackBar.showError(context, 'Counter is Already Zero');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonIconData(
                      icanData: Icons.arrow_back_outlined,
                      bgColor: theme.colorScheme.surface.withAlpha(
                        (255 * 0.1).toInt(),
                      ),
                    ),
                    Text(
                      AppTitles.tasbih,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CommonIconData(
                      icanData: Icons.history,
                      iconColor: theme.colorScheme.onPrimary,
                      bgColor: theme.colorScheme.surface.withAlpha(
                        (255 * 0.1).toInt(),
                      ),
                    ),
                  ],
                ).paddingAll(8.0),
              ),
              titlePadding: EdgeInsets.only(bottom: 18),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.transparent),
              child: WierdCard(),
            ).paddingAll(20),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 350,
              child: Center(
                child: GestureDetector(
                  onTap: _incrementCounter,
                  child: Container(
                    height: 260,
                    width: 230,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        // tileMode: TileMode.,
                        colors: [
                          theme.colorScheme.onSurface.withAlpha(
                            (255 * 0.4).toInt(),
                          ),
                          theme.colorScheme.onSurface.withAlpha(
                            (255 * 0.1).toInt(),
                          ),
                          theme.colorScheme.onSurface.withAlpha(
                            (255 * 0.2).toInt(),
                          ),
                        ],
                      ),
                      // color: Colors.black12,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.onSurface.withAlpha(
                            (255 * 0.2).toInt(),
                          ),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      // color: theme.colorScheme.surface.withAlpha(
                      //   (255 * 0.9).toInt(),
                      // ),
                    ),

                    child: Center(
                      child: SizedBox(
                        height: 220,
                        width: 190,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppTitles.count,
                              style: theme.textTheme.labelMedium!.copyWith(
                                color: theme.colorScheme.onPrimary.withAlpha(
                                  (255 * 0.2).toInt(),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _counter,
                              builder: (context, value, child) {
                                return Text(
                                  _counter.value.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            Text(
                              AppTitles.wierdTime1.toString(),
                              style: theme.textTheme.labelLarge!.copyWith(
                                color: theme.colorScheme.onPrimary.withAlpha(
                                  (255 * 0.2).toInt(),
                                ),
                              ),
                            ),
                          ],
                        ).paddingAll(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: Center(
                child: GestureDetector(
                  onTap: restCounter,
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: theme.colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.onSurface.withAlpha(
                            (255 * 0.2).toInt(),
                          ),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: theme.colorScheme.surface,
                          size: 25,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppTitles.rest,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.onPrimary.withAlpha(
                              (255 * 0.8).toInt(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

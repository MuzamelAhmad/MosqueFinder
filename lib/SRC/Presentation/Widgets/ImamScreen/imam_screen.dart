import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/CustomDrawer/customize_drawer_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/components/imam_pray_card.dart';

class ImamScreen extends StatefulWidget {
  const ImamScreen({super.key});

  @override
  State<ImamScreen> createState() => _ImamScreenState();
}

class _ImamScreenState extends State<ImamScreen> {
  final List<Map<String, dynamic>> prayerTimes = [
    {'prayName': 'Fajr', 'prayTime': '5:50'},
    {'prayName': 'Dhuhr', 'prayTime': '12:30'},
    {'prayName': 'Asr', 'prayTime': '4:30'},
    {'prayName': 'Maghrib', 'prayTime': '6:30'},
    {'prayName': 'Isha', 'prayTime': '8:00'},
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: CustomizeDrawerScreen(),
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: theme.iconTheme,
                expandedHeight: 150,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: Column(
                  children: [
                    Text(
                      'Pray Timing',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ImamPrayCard(
                      widget: Center(
                        child: Text(
                          'Edit The Pray Timings',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: prayerTimes.length,
                itemBuilder: (context, index) {
                  return ImamPrayCard(
                    widget: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              prayerTimes[index]['prayName'],
                              textAlign: TextAlign.left,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              prayerTimes[index]['prayTime'],
                              textAlign: TextAlign.left,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Icon(Icons.edit_calendar_outlined)),
                        ],
                      ).paddingAll(10),
                    ),
                  ).paddingOnly(top: 10.h, bottom: 10.h);
                },
              ),
            ],
          ).paddingSymmetric(horizontal: 20.w, vertical: 20.h),
        ),
      ),
    );
  }
}

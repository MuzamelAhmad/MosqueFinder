import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final count = await SharedPrefsService.getTasbihCount();
    _counter.value = count;
  }

  void _incrementCounter() {
    _counter.value++;
    SharedPrefsService.saveTasbihCount(_counter.value);
  }

  Future<void> restCounter() async {
    if (_counter.value != 0) {
      // ✅ Save to history before resetting
      await SharedPrefsService.addToTasbihHistory(_counter.value);
      
      _counter.value = 0;
      await SharedPrefsService.saveTasbihCount(0);
      
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Count saved to history and reset ✅');
      }
    } else {
      CustomSnackBar.showError(context, 'Counter is Already Zero');
    }
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.indigo.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasbeeh History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      await SharedPrefsService.clearTasbihHistory();
                      if (mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            
            // List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: SharedPrefsService.getTasbihHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final history = snapshot.data ?? [];
                  if (history.isEmpty) {
                    return const Center(
                      child: Text('No history yet', style: TextStyle(color: Colors.white70)),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final count = item['count'];
                      final date = DateTime.parse(item['date']);
                      final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          'Session Completed',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                        ),
                        trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
              title: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonIconData(
                      icanData: Icons.arrow_back_outlined,
                      bgColor: theme.colorScheme.surface.withAlpha(
                        (255 * 0.1).toInt(),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    Text(
                      AppTitles.tasbih,
                      style: const TextStyle(
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
                      onTap: _showHistorySheet,
                    ),
                  ],
                ).paddingAll(8.0),
              ),
              titlePadding: EdgeInsets.zero,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: const WierdCard(),
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
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
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

import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/CustomDrawer/customize_drawer_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/signup/pray_timer.dart';

class ImamScreen extends StatefulWidget {
  final String userId; // 👈 received from PrayTimer

  const ImamScreen({super.key, required this.userId});

  @override
  State<ImamScreen> createState() => _ImamScreenState();
}

class _ImamScreenState extends State<ImamScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch imam data when screen opens
    context.read<ImamCubit>().getImamData();
  }

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
          // PrayTimer handles its own cubit state internally
          child: PrayTimer(userId: widget.userId),
        ),
      ),
    );
  }
}

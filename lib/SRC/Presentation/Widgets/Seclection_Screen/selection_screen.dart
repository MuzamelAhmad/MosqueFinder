import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Muqtadi/muqtadi_cubit.dart';
import 'package:mosque_finder/SRC/Application/Utils/Extensions/padding.dart';
import 'package:mosque_finder/SRC/Data/Resources/App_Paths/paths.dart';
import 'package:mosque_finder/SRC/Data/Resources/colors/app_colors.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/Login/login_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Seclection_Screen/components/selection_card.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/bottom_navigation/bottom_navigation_screen.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  void Function()? muqtadi() {
    context.read<MuqtadiCubit>().fetchNearbyMosques();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavigationScreen()),
    );
    return null;
  }

  void Function()? imam() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectionCard(
                title: 'Muqtadi',
                iConData: AppPath.muqtadi,
                Ontap: muqtadi,
              ),
              SizedBox(width: 5.w),
              SelectionCard(title: 'Imam', iConData: AppPath.imam, Ontap: imam),
            ],
          ).paddingAll(15.r),
        ),
      ),
    );
  }
}

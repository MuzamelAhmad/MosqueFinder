import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosque_finder/SRC/Data/Resources/ThemesData/light_theme.dart';
import 'package:mosque_finder/SRC/Presentation/Common/PasswordTextField/controller/password_controller.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Seclection_Screen/selection_screen.dart';
import 'package:provider/provider.dart';

// import 'package:timezone/data/latest.dart' as tz;

import 'SRC/Data/repositories/DI_Services/mosque_DI.dart';
import 'SRC/Presentation/Common/TextFromField/Controller/text_field_controller.dart';
import 'SRC/Presentation/Widgets/PrayerTimesScreen/controller/hijri_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // tz.initializeTimeZones(); // ← important!
  runApp(const MyApp());
  getIt.registerLazySingleton<MosqueDiServices>(() => MosqueDiServices());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HijriProvider()),
        ChangeNotifierProvider(create: (_) => PasswordController()),
        ChangeNotifierProvider(create: (_) => TextFieldController()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_, child) {
          return MaterialApp(
            title: 'Mosque Finder',
            builder: (context, child) {
              return Theme(data: LightTheme.getTheme(context), child: child!);
            },

            debugShowCheckedModeBanner: false,
            // initialRoute: '/',

            // 2. Create the Route Map
            // routes: {
            //   // '/selection': (context) => const SelectionScreen(),
            //   '/mainPage': (context) => const BottomNavigationScreen(),
            //   '/login': (context) => const LoginScreen(),
            //   '/signup': (context) => const SignupScreen(),
            // },
            home: const SelectionScreen(),
          );
        },
      ),
    );
  }
}

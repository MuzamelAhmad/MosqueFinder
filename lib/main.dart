import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosque_finder/SRC/Data/Resources/ThemesData/light_theme.dart';
import 'package:mosque_finder/SRC/Presentation/Common/PasswordTextField/controller/password_controller.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Seclection_Screen/selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:timezone/data/latest.dart' as tz;

import 'SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'SRC/Application/Services/shared_prefs_service.dart';
import 'SRC/Application/Services/notification_service.dart';
import 'SRC/Data/repositories/DI_Services/mosque_DI.dart';
import 'SRC/Presentation/Common/TextFromField/Controller/text_field_controller.dart';
import 'SRC/Presentation/Widgets/PrayerTimesScreen/controller/hijri_provider.dart';
import 'SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: dotenv.env['Supabase_url']!,
    anonKey: dotenv.env['Supabase_anon_key']!,
  );
  
  await NotificationService.init();
  await NotificationService.requestPermissions();

  final String? savedUserId = await SharedPrefsService.getUserId();
  
  runApp(MyApp(initialUserId: savedUserId));
  getIt.registerLazySingleton<MosqueDiServices>(() => MosqueDiServices());
}

class MyApp extends StatelessWidget {
  final String? initialUserId;
  const MyApp({super.key, this.initialUserId});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => ImamCubit())],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HijriProvider()),
          ChangeNotifierProvider(create: (_) => PasswordController()),
          ChangeNotifierProvider(create: (_) => TextFieldController()),
        ],
        child: ScreenUtilInit(
          designSize: Size(MediaQuery.widthOf(context), MediaQuery.heightOf(context)),
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
              home: initialUserId != null
                  ? ImamScreen(userId: initialUserId!)
                  : const SelectionScreen(),
            );
          },
        ),
      ),
    );
  }
}

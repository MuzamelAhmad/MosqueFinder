import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosque_finder/SRC/Data/Resources/ThemesData/light_theme.dart';
import 'package:mosque_finder/SRC/Presentation/Common/PasswordTextField/controller/password_controller.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/ForgetPassword/reset_password_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Seclection_Screen/selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:timezone/data/latest.dart' as tz;

import 'SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'SRC/Application/Cubit/Muqtadi/muqtadi_cubit.dart';
import 'SRC/Application/Services/shared_prefs_service.dart';
import 'SRC/Application/Services/notification_service.dart';
import 'SRC/Data/repositories/DI_Services/mosque_DI.dart';
import 'SRC/Presentation/Common/TextFromField/Controller/text_field_controller.dart';
import 'SRC/Presentation/Widgets/PrayerTimesScreen/controller/hijri_provider.dart';
import 'SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';
import 'SRC/Presentation/Widgets/SplashScreen/splash_screen.dart';

// ✅ Global navigator key for background navigation (like password reset)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: dotenv.env['Supabase_url']!,
    anonKey: dotenv.env['Supabase_anon_key']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  
  await NotificationService.init();
  // Permission will be requested when user enables notifications or sets times

  runApp(const MyApp());
  getIt.registerLazySingleton<MosqueDiServices>(() => MosqueDiServices());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // ✅ Listen for password recovery events from Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Navigate to reset password screen
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ImamCubit()),
        BlocProvider(create: (context) => MuqtadiCubit()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HijriProvider()),
          ChangeNotifierProvider(create: (_) => PasswordController()),
          ChangeNotifierProvider(create: (_) => TextFieldController()),
        ],
        child: ScreenUtilInit(
          designSize: Size(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              navigatorKey: navigatorKey, // ✅ Assign the global key
              title: 'Mosque Finder',
              builder: (context, child) {
                return Theme(data: LightTheme.getTheme(context), child: child!);
              },
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Application/Services/shared_prefs_service.dart';
import 'package:mosque_finder/SRC/Application/Services/notification_service.dart';
import 'package:mosque_finder/SRC/Data/Resources/Validator/validators.dart';
import 'package:mosque_finder/SRC/Presentation/Common/SocialLoginMethods/social_account_card.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/signup/signup_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/signup/complete_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _handleLoginSuccess(BuildContext context, String userId) async {
    final bool hasPerms = await NotificationService.hasPermissions();

    if (!hasPerms && mounted) {
      // Show professional permission dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.indigo.shade900,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.white),
              SizedBox(width: 12),
              Text('Enable Alerts', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'To provide you with punctual prayer reminders, Salah 360 needs your permission to show notifications and set alarms.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToImamScreen(userId);
              },
              child:
                  const Text('Skip', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await NotificationService.requestPermissions();
                _navigateToImamScreen(userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              child:
                  const Text('Enable', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      _navigateToImamScreen(userId);
    }
  }

  void _navigateToImamScreen(String userId) {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => ImamScreen(userId: userId),
      ),
      (route) => false,
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TextFieldController>(context, listen: false);
    final theme = Theme.of(context);

    return BlocListener<ImamCubit, ImamState>(
      listener: (context, state) {
        // ── Login Success → go to ImamScreen ───
        if (state is ImamLoginSuccess) {
          // ✅ Persist login state
          SharedPrefsService.saveUserId(state.userId);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ImamScreen(userId: state.userId),
            ),
            (route) => false, // 👈 clears login stack
          );
        }

        // ── Login Error ────────────────────────
        if (state is ImamLoginError) {
          CustomSnackBar.showError(context, state.message);
        }

        // ── Social Login Incomplete ──────────────
        if (state is ImamSocialLoginIncomplete) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompleteProfileScreen(
                userId: state.userId,
                email: state.email,
                fullName: state.name,
              ),
            ),
          );
        }
      },
      child: Scaffold(
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Welcome Imam!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 350.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login Now',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Consumer<TextFieldController>(
                                builder: (context, value, child) {
                                  return TextFromFieldCommon(
                                    controller: value.text,
                                    validator: (value) => Validators().validateEmail(value),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    isIconShow: true,
                                    iConData: Icons.cancel_outlined,
                                    hintTitle: 'Email',
                                    onTap: () {
                                      if (value.text.text.isNotEmpty) {
                                        value.clearText();
                                      } else {
                                        return;
                                      }
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: 10.h),
                              Consumer<PasswordController>(
                                builder: (context, value, child) {
                                  return PasswordFormField(
                                    controller: value.getPassword,
                                    validator: (value) => Validators().validatePassword(value),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    hintTitle: 'Password',
                                    show: value.isObscureText,
                                    onTap: () {
                                      value.toggleObscureText();
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: 5.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgetPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forget Password ?',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                            ],
                          ),
                        ),

                        // ── Login Button ──────────────────────
                        BlocBuilder<ImamCubit, ImamState>(
                          builder: (context, state) {
                            final isLoading = state is ImamLoading;
                            return isLoading
                                ? const CircularProgressIndicator()
                                : CustomBotton(
                                    text: 'Login',
                                    onTap: () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final textController =
                                          Provider.of<TextFieldController>(
                                            context,
                                            listen: false,
                                          );
                                      final passwordController =
                                          Provider.of<PasswordController>(
                                            context,
                                            listen: false,
                                          );

                                      // Validate fields
                                      if (textController.text.text
                                          .trim()
                                          .isEmpty) {
                                        CustomSnackBar.showError(context, 'Email is required');
                                        return;
                                      }

                                      if (passwordController.getPassword.text
                                          .trim()
                                          .isEmpty) {
                                        CustomSnackBar.showError(context, 'Password is required');
                                        return;
                                      }

                                      // 👈 Call login via cubit
                                      context.read<ImamCubit>().login(
                                        email: textController.text.text.trim(),
                                        password: passwordController
                                            .getPassword
                                            .text
                                            .trim(),
                                      );
                                      // print(
                                      //   "login data -----------${textController.text.text.trim()}",
                                      // );
                                      // print(
                                      //   "login data -----------${passwordController.getPassword.text.trim()}",
                                      // );
                                    },
                                  );
                          },
                        ),
                      ],
                    ),
                  ),

                  SocialAccountCard(
                    title1: 'Don\'t have an account? ',
                    title2: 'Sign Up',
                    onTap: () {
                      context.read<TextFieldController>().allClear();
                      context.read<PasswordController>().clearPasswords();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 20.w, vertical: 40.h),
            ),
          ),
        ),
      ),
    );
  }
}

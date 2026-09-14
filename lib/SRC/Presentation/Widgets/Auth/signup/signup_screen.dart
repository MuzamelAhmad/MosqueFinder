import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Validator/validators.dart';
import 'package:mosque_finder/SRC/Data/Resources/export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Common/SocialLoginMethods/social_account_card.dart';
import 'package:mosque_finder/SRC/Presentation/Common/Utils/snack_bar_utils.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/Login/login_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/signup/pray_timer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with WidgetsBindingObserver {
  // Holds location data after picked
  double? _latitude;
  double? _longitude;
  String _cityName = '';
  String? passChecker;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Automatically check for location if user returns from settings
    if (state == AppLifecycleState.resumed && _latitude == null) {
      context.read<ImamCubit>().pickLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TextFieldController>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<ImamCubit, ImamState>(
        listener: (context, state) {
          // ── Location states ──────────────────────
          if (state is ImamLocationLoaded) {
            setState(() {
              _latitude = state.latitude;
              _longitude = state.longitude;
              _cityName = state.city;
            });
          }
          if (state is ImamLocationError) {
            CustomSnackBar.showError(context, state.message);
          }

          // ── Signup states ────────────────────────
          if (state is ImamSignupSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrayTimer(userId: state.userId),
              ),
            );
          }
          if (state is ImamSignupError) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        child: Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'Create Imam Account',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    child: Form(
                      autovalidateMode: AutovalidateMode.disabled,
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
                                onTap: () => value.clearText(),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          Consumer<TextFieldController>(
                            builder: (context, value, child) {
                              return TextFromFieldCommon(
                                controller: value.fullName,
                                validator: (value) => value!.isEmpty ? 'Name required' : null,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                isIconShow: true,
                                iConData: Icons.cancel_outlined,
                                hintTitle: 'Full Name',
                                onTap: () => value.fullNameClearText(),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          Consumer<TextFieldController>(
                            builder: (context, value, child) {
                              return TextFromFieldCommon(
                                controller: value.mosqueName,
                                validator: (value) => value!.isEmpty ? 'Mosque required' : null,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                isIconShow: true,
                                iConData: Icons.cancel_outlined,
                                hintTitle: 'Mosque Name',
                                onTap: () => value.mosqueNameClearText(),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          Consumer<PasswordController>(
                            builder: (context, value, child) {
                              return PasswordFormField(
                                controller: value.getPassword,
                                validator: (value) {
                                  Validators().validatePassword(value);
                                  passChecker = value;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                hintTitle: 'Password',
                                show: value.isObscureText,
                                onTap: () => value.toggleObscureText(),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          Consumer<PasswordController>(
                            builder: (context, value, child) {
                              return PasswordFormField(
                                controller: value.confPassword,
                                validator: (value) => Validators().validateConfirmPassword(value, passChecker),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                hintTitle: 'Confirm Password',
                                show: value.getObscureText,
                                onTap: () => value.toggleConfObscureText(),
                              );
                            },
                          ),
                        ],
                      ),
                    ).paddingSymmetric(horizontal: 20.w),
                  ),
                  SizedBox(height: 24.h),
                  
                  // ── Location Picker ─────────────────────
                  BlocBuilder<ImamCubit, ImamState>(
                    builder: (context, state) {
                      final isLoading = state is ImamLocationLoading;
                      return GestureDetector(
                        onTap: isLoading ? null : () => context.read<ImamCubit>().pickLocation(),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: _latitude != null ? Colors.greenAccent : Colors.white24,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isLoading
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Icon(
                                      _latitude != null ? Icons.location_on_rounded : Icons.location_searching_rounded,
                                      color: _latitude != null ? Colors.greenAccent : Colors.white,
                                      size: 22.r,
                                    ),
                              SizedBox(width: 12.w),
                              Text(
                                _latitude != null ? '📍 $_cityName' : 'Detect Mosque Location',
                                style: TextStyle(
                                  color: _latitude != null ? Colors.greenAccent : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),

                  // ── Signup Button ───────────────────────
                  BlocBuilder<ImamCubit, ImamState>(
                    builder: (context, state) {
                      final isLoading = state is ImamLoading;
                      return isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : CustomBotton(
                              text: 'Sign Up',
                              onTap: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                final textController = context.read<TextFieldController>();
                                final passwordController = context.read<PasswordController>();

                                if (_latitude == null || _longitude == null) {
                                  CustomSnackBar.showError(context, 'Please detect location first');
                                  return;
                                }

                                context.read<ImamCubit>().signUp(
                                  email: textController.text.text.trim(),
                                  password: passwordController.getPassword.text.trim(),
                                  fullName: textController.fullName.text.trim(),
                                  latitude: _latitude!,
                                  longitude: _longitude!,
                                  city: _cityName,
                                  mosqueName: textController.mosqueName.text.trim(),
                                );
                              },
                            );
                    },
                  ).paddingSymmetric(horizontal: 20.w),

                  SizedBox(height: 20.h),
                  SocialAccountCard(
                    title1: 'Already have an account? ',
                    title2: 'Sign In',
                    onTap: () {
                      context.read<TextFieldController>().allClear();
                      context.read<PasswordController>().clearPasswords();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                  ),
                  SizedBox(height: 40.h),
                ],
              ).paddingSymmetric(horizontal: 20.w, vertical: 20.h),
            ),
          ),
        ),
      ),
    );
  }
}

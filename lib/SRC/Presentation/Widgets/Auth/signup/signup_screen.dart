import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Validator/validators.dart';
import 'package:mosque_finder/SRC/Data/Resources/export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Common/SocialLoginMethods/social_account_card.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/Login/login_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/signup/pray_timer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Holds location data after picked
  double? _latitude;
  double? _longitude;
  String _cityName = '';
  String? passChecker;

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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Welcome Sign Up',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 350.h,
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: GlobalKey<FormState>(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Consumer<TextFieldController>(
                              builder: (context, value, child) {
                                return TextFromFieldCommon(
                                  controller: value.text,
                                  validator: (value) {
                                    return Validators().validateEmail(value);
                                  },
                                  isIconShow: true,
                                  iConData: Icons.cancel_outlined,
                                  hintTitle: 'Email',
                                  onTap: () {
                                    if (value.text.text.isNotEmpty) {
                                      value.clearText();
                                    } else {
                                      return null;
                                    }
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 10.h),
                            Consumer<TextFieldController>(
                              builder: (context, value, child) {
                                return TextFromFieldCommon(
                                  controller: value.fullName,
                                  validator: (value) {},
                                  isIconShow: true,
                                  iConData: Icons.cancel_outlined,
                                  hintTitle: 'Full Name',
                                  onTap: () {
                                    if (value.fullName.text.isNotEmpty) {
                                      value.fullNameClearText();
                                    } else {
                                      return null;
                                    }
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 10.h),
                            Consumer<TextFieldController>(
                              builder: (context, value, child) {
                                return TextFromFieldCommon(
                                  controller: value.mosqueName,
                                  validator: (value) {},
                                  isIconShow: true,
                                  iConData: Icons.cancel_outlined,
                                  hintTitle: 'Mosque Name',
                                  onTap: () {
                                    if (value.mosqueName.text.isNotEmpty) {
                                      value.mosqueNameClearText();
                                    } else {
                                      return null;
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
                                  validator: (value) {
                                    Validators().validatePassword(value);
                                    passChecker = value;
                                  },
                                  hintTitle: 'Password',
                                  show: value.isObscureText,
                                  onTap: () {
                                    value.toggleObscureText();
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 10.h),
                            Consumer<PasswordController>(
                              builder: (context, value, child) {
                                return PasswordFormField(
                                  controller: value.confPassword,
                                  validator: (value) {
                                    return Validators().validateConfirmPassword(
                                      value,
                                      passChecker,
                                    );
                                  },
                                  hintTitle: 'Confirm Password',
                                  show: value.getObscureText,
                                  onTap: () {
                                    value.toggleConfObscureText();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ).paddingOnly(top: 10.h, bottom: 10.h),
                    ),
                    // ── Location Picker ─────────────────────
                    BlocBuilder<ImamCubit, ImamState>(
                      builder: (context, state) {
                        final isLoading = state is ImamLocationLoading;
                        return GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => context.read<ImamCubit>().pickLocation(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _latitude != null
                                    ? Colors.green
                                    : theme.colorScheme.onPrimary.withOpacity(
                                        0.5,
                                      ),
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isLoading
                                    ? SizedBox(
                                        width: 18.w,
                                        height: 18.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Icon(
                                        _latitude != null
                                            ? Icons.location_on
                                            : Icons.location_off_outlined,
                                        color: _latitude != null
                                            ? Colors.green
                                            : theme.colorScheme.onPrimary,
                                        size: 20.sp,
                                      ),
                                SizedBox(width: 8.w),
                                Text(
                                  _latitude != null
                                      ? '📍 $_cityName'
                                      : 'Pick Your Location',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _latitude != null
                                        ? Colors.green
                                        : theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    // ── Signup Button ───────────────────────
                    BlocBuilder<ImamCubit, ImamState>(
                      builder: (context, state) {
                        final isLoading = state is ImamLoading;
                        return isLoading
                            ? const CircularProgressIndicator()
                            : CustomBotton(
                                text: 'Sign Up',
                                onTap: () {
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

                                  if (_latitude == null || _longitude == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please pick your location first',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<ImamCubit>().signUp(
                                    email: textController.text.text.trim(),
                                    password: passwordController
                                        .getPassword
                                        .text
                                        .trim(),
                                    fullName: textController.fullName.text
                                        .trim(),
                                    latitude: _latitude!,
                                    longitude: _longitude!,
                                    city: _cityName,
                                    mosqueName: textController.mosqueName.text
                                        .trim(),
                                  );
                                },
                              );
                      },
                    ),
                    SizedBox(height: 10.h),
                    SocialAccountCard(
                      title1: 'Already have an account? ',
                      Title2: 'Sign In',
                      OnTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ).paddingSymmetric(horizontal: 20.h, vertical: 20.h),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

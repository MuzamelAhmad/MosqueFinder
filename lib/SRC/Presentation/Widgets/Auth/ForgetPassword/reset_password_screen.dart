import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/Login/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passwordController = context.read<PasswordController>();

    return BlocConsumer<ImamCubit, ImamState>(
      listener: (context, state) {
        if (state is ImamPasswordUpdateSuccess) {
          CustomSnackBar.showSuccess(context, 'Password updated successfully! Please login.');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
        if (state is ImamPasswordUpdateError) {
          CustomSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 50.h),
                    Text(
                      "Set New Password",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Enter your new password below",
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    SizedBox(height: 40.h),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Consumer<PasswordController>(
                            builder: (context, value, child) {
                              return PasswordFormField(
                                controller: value.getPassword,
                                validator: (val) {
                                  if (val == null || val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                hintTitle: 'New Password',
                                show: value.isObscureText,
                                onTap: () => value.toggleObscureText(),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),
                          Consumer<PasswordController>(
                            builder: (context, value, child) {
                              return PasswordFormField(
                                controller: value.confPassword,
                                validator: (val) {
                                  if (val != value.getPassword.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                hintTitle: 'Confirm New Password',
                                show: value.getObscureText,
                                onTap: () => value.toggleConfObscureText(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    state is ImamLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : CustomBotton(
                            text: 'Update Password',
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ImamCubit>().updatePassword(
                                      newPassword: passwordController.getPassword.text.trim(),
                                    );
                              }
                            },
                          ),
                  ],
                ).paddingSymmetric(horizontal: 24.w, vertical: 20.h),
              ),
            ),
          ),
        );
      },
    );
  }
}

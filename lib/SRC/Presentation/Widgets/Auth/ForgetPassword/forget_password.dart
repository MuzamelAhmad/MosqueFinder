import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosque_finder/SRC/Application/Cubit/Imam/imam_cubit.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ImamCubit, ImamState>(
      listener: (context, state) {
        if (state is ImamForgetPasswordSuccess) {
          CustomSnackBar.showSuccess(context, 'Password reset link sent to your email ✅');
          // Optional: Navigate back to login after success
          // Navigator.pop(context);
        }
        if (state is ImamForgetPasswordError) {
          CustomSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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
                  children: [
                    SizedBox(height: 50.h),
                    Text(
                      "Forget Password",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Enter your email address and we'll send you a link to reset your password.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Consumer<TextFieldController>(
                      builder: (context, value, child) {
                        return TextFromFieldCommon(
                          controller: value.text,
                          validator: (email) {
                            if (email == null || email.isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(email)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          isIconShow: true,
                          iConData: Icons.cancel_outlined,
                          hintTitle: 'Email',
                          onTap: () {
                            if (value.text.text.isNotEmpty) {
                              value.clearText();
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 30.h),
                    state is ImamLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : CustomBotton(
                            text: 'Send Link',
                            onTap: () {
                              final controller =
                                  Provider.of<TextFieldController>(context,
                                      listen: false);
                              final email = controller.text.text.trim();

                              if (email.isEmpty) {
                                CustomSnackBar.showError(context, 'Please enter your email');
                                return;
                              }

                              context
                                  .read<ImamCubit>()
                                  .forgetPassword(email: email);
                            },
                          ),
                  ],
                ).paddingSymmetric(horizontal: 20.w, vertical: 20.h),
              ),
            ),
          ),
        );
      },
    );
  }
}

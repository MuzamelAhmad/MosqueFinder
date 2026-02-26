import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Validator/validators.dart';
import 'package:mosque_finder/SRC/Data/Resources/export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Common/SocialLoginMethods/social_account_card.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/Login/login_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    Provider.of<TextFieldController>(context, listen: false);
    final theme = Theme.of(context);
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
                              validator: (value) {},
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
                                return null;
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
                              validator: (value) {},
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
                CustomBotton(
                  text: 'Sign Up',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImamScreen()),
                    );
                  },
                ),
                SocialAccountCard(
                  title1: 'Already have an account? ',
                  Title2: 'Sign In',
                  OnTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ).paddingSymmetric(horizontal: 20.h, vertical: 20.h),
          ),
        ),
      ),
    );
  }
}

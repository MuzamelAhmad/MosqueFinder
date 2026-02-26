import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Data/Resources/Export/exports.dart';
import 'package:mosque_finder/SRC/Presentation/Common/SocialLoginMethods/social_account_card.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/Auth/signup/signup_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/ImamScreen/imam_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void Function()? textFromField(value) {
    if (value.text.text.isNotEmpty) {
      value.text.clear();
    } else {
      return null;
    }
    return null;
  }

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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: .topStart,
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
                        child: Column(
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
                            Consumer<PasswordController>(
                              builder: (context, value, child) {
                                return PasswordFormField(
                                  controller: value.getPassword,
                                  validator: (value) {},
                                  hintTitle: 'Password',
                                  show: value.isObscureText,
                                  onTap: () {
                                    value.toggleObscureText();
                                  },
                                );
                              },
                            ),
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
                                  "Forget Password ?",
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).paddingAll(10),
                      CustomBotton(
                        text: 'Login',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImamScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SocialAccountCard(
                  title1: 'Don\'t have an account? ',
                  Title2: 'Sign Up',
                  OnTap: () {
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
    );
  }
}

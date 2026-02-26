import 'package:flutter/material.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Forget Password",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 250.h,
                child: Consumer<TextFieldController>(
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
              ),
              CustomBotton(text: 'Send', onTap: () {}),
            ],
          ).paddingSymmetric(horizontal: 20.w, vertical: 10.h),
        ),
      ),
    );
  }
}

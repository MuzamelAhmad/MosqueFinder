import 'package:flutter/material.dart';

class PasswordFormField extends StatelessWidget {
  final String? hintTitle;
  final bool show;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final AutovalidateMode? autovalidateMode;
  const PasswordFormField({
    super.key,
    this.hintTitle,
    required this.show,
    this.onTap,
    this.validator,
    this.controller,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: autovalidateMode,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      obscureText: show,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white24,
        suffixIcon: IconButton(
          icon: show
              ? Icon(
                  Icons.visibility_off_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                )
              : Icon(
                  Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          onPressed: onTap,
        ),
        label: Text(hintTitle!),
      ),
    );
  }
}

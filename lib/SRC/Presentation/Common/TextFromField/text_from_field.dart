import 'package:flutter/material.dart';

class TextFromFieldCommon extends StatelessWidget {
  final String? hintTitle;
  final IconData? iConData;
  final bool? isIconShow;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final AutovalidateMode? autovalidateMode;
  const TextFromFieldCommon({
    super.key,
    this.hintTitle,
    this.iConData,
    this.isIconShow,
    this.onTap,
    this.validator,
    this.controller,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).colorScheme.onPrimary,
      controller: controller,
      validator: validator,
      autovalidateMode: autovalidateMode,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        label: Text(hintTitle!),
        fillColor: Colors.white24,
        suffixIcon: IconButton(
          onPressed: onTap,
          icon: isIconShow == true || iConData != null
              ? Icon(iConData, color: Theme.of(context).colorScheme.onPrimary)
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}

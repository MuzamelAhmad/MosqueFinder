import 'package:flutter/material.dart';

class PasswordController with ChangeNotifier {
  bool obscureText = true;
  bool confObscureText = true;
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool get isObscureText => obscureText;
  bool get getObscureText => confObscureText;
  TextEditingController get getPassword => password;
  TextEditingController get confPassword => confirmPassword;

  void toggleObscureText() {
    obscureText = !obscureText;
    notifyListeners();
  }

  void toggleConfObscureText() {
    confObscureText = !confObscureText;
    notifyListeners();
  }

  void setPassword(TextEditingController value) {
    password = value;
    notifyListeners();
  }

  void setConfPassword(TextEditingController confirmPassword) {
    this.confirmPassword = confirmPassword;
    notifyListeners();
  }

  void clearPasswords() {
    password.clear();
    confirmPassword.clear();
    notifyListeners();
  }
}

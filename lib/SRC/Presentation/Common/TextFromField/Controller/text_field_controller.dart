import 'package:flutter/material.dart';

class TextFieldController with ChangeNotifier {
  TextEditingController textEditingController = TextEditingController();
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mosqueNameEditingController = TextEditingController();

  TextEditingController get text => textEditingController;
  TextEditingController get fullName => nameEditingController;
  TextEditingController get mosqueName => mosqueNameEditingController;

  void setText(TextEditingController value) {
    textEditingController = value;
    notifyListeners();
  }

  void setFullName(TextEditingController name) {
    nameEditingController = name;
    notifyListeners();
  }

  void setMosqueName(TextEditingController mosqueName) {
    mosqueNameEditingController = mosqueName;
    notifyListeners();
  }

  void clearText() {
    textEditingController.clear();
    notifyListeners();
  }

  void fullNameClearText() {
    nameEditingController.clear();
    notifyListeners();
  }

  void mosqueNameClearText() {
    mosqueNameEditingController.clear();
    notifyListeners();
  }

  void allClear() {
    textEditingController.clear();
    nameEditingController.clear();
    mosqueNameEditingController.clear();
    notifyListeners();
  }
}

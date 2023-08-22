import 'package:flutter/material.dart';

class infostore extends ChangeNotifier {
  String email = "";
  String password = "";
  String checkPassword = "";
  String username = "";
  String academy = "";
  bool isLoading= false;
  String? gender;



  chagneAcademy(String academyName){
    academy = academyName;
    notifyListeners();
  }
}

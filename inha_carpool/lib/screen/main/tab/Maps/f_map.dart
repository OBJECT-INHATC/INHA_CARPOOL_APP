import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/main/tab/Maps/w_google_map.dart';

class GoogleMapsApp extends StatelessWidget {
  final String admin;

  const GoogleMapsApp({Key? key, required this.admin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('$admin의 카풀')),
        body: const GoogleMapsWidget(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:inha_Carpool/screen/main/tab/Maps/w_google_map.dart';

void main() => runApp(const GoogleMapsApp());

class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('000의 카풀 방')),
        body: const GoogleMapsWidget(),
      ),
    );
  }
}
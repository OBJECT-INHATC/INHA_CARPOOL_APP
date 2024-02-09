import 'package:flutter/material.dart';

class CustomPng extends StatelessWidget {

  final String fileDirectory;
  final String fileName;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CustomPng({
    required this.fileDirectory,
    required this.fileName,
    this.fit = BoxFit.contain,
    required this.width,
    required this.height,
    super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset("assets/image/$fileDirectory/$fileName.png", fit: fit,),
    );
  }

}

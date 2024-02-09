import 'package:flutter/material.dart';

class Category extends StatelessWidget {
  const Category({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 14.0),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

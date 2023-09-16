import 'package:flutter/material.dart';

class EmptySearchedCarpool extends StatelessWidget {
  const EmptySearchedCarpool({super.key});


  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          '검색 결과가 없습니다!',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

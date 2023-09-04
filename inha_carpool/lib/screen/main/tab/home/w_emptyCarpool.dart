import 'package:flutter/material.dart';

class EmptyCarpool extends StatelessWidget {
  const EmptyCarpool({super.key});


  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          '진행중인 카풀이 없습니다!\n카풀을 등록해보세요!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

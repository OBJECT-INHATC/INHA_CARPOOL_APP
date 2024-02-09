import 'package:flutter/material.dart';

/// 검새 결과 없을 때 반환할 위젯
class EmptySearched extends StatelessWidget {
  const EmptySearched({super.key});

  final String message = '검색 결과가 없습니다.';

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

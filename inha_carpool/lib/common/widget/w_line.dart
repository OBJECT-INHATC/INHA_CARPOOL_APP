import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/extension/context_extension.dart';

import '../common.dart';

class Line extends StatelessWidget {
  const Line({
    Key? key,
    this.color,
    this.height = 1,
    this.margin,
  }) : super(key: key);

  final Color? color;
  final EdgeInsets? margin;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      color: color ?? context.appColors.divider,
      height: height,
    );
  }
}

class VerticalLine extends StatelessWidget {

  const VerticalLine({
    Key? key,
    this.color,
    this.width = 1, // 수직선의 너비
    this.height = 1,
    this.margin,
  }) : super(key: key);

  final Color? color;
  final EdgeInsets? margin;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        color: color ?? context.appColors.divider,
        width: width, // 수직선의 너비 설정
        height: height // 수직선의 너비 설정,
    );
  }
}

//역삼각형
class dwonTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0) // 왼쪽 위
      ..lineTo(size.width, 0) // 오른쪽 위
      ..lineTo(size.width / 2, size.height) // 아래 중앙
      ..close();

    final paint = Paint()
      ..color = Color(0xFFFAFAFA) //grey[100] 배경색과 동일
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//삼각형
class UpTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0) // 중앙 위
      ..lineTo(0, size.height) // 왼쪽 아래
      ..lineTo(size.width, size.height) // 오른쪽 아래
      ..close();

    final paint = Paint()..color = Color(0xFFFAFAFA);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
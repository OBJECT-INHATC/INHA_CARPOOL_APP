import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class SplashOpacity extends StatelessWidget {
  const SplashOpacity({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.height(1);

    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: screenHeight * 0.15,
      // 위쪽 여백 설정
      start: 0,
      // 시작점에서의 여백 없음
      end: 0,
      // 끝점에서의 여백 없음
      height: screenHeight * 0.45,
      child: Opacity(
        opacity: 0.3, // 투명도 설정
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/splash/splash.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

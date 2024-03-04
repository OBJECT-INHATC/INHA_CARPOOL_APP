import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class ChatNotice extends StatelessWidget {
  const ChatNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.width(1);

    return ExpansionTile(
      title: Padding(
        padding: EdgeInsets.all(screenHeight * 0.01),
        child: Text(
          '카풀 이용 공지사항',
          style: TextStyle(
            fontSize: screenHeight * 0.035,
            fontWeight: FontWeight.bold,
          color: context.appColors.logoColor,
          ),

        ),
      ),
      iconColor: context.appColors.logoColor,

      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenHeight * 0.03,
            vertical: screenHeight * 0.03,
          ),
          child: Text(
            '1. 상대방을 모욕하거나 비방하는 내용은 삼가해 주세요.'
                '\n\n'
                '2. 사적인 금전 거래는 불가합니다.\n  - 카풀 이용 시에는 만나서 학생 확인 후 이체를 부탁드립니다.'
                '\n\n'
                '3. 성희롱 발언 등 불건전한 행위는 엄격히 금지됩니다.'
                '\n\n'
                '4. 카풀에서 발생하는 모든 문제는 사용자간의 책임입니다. 카풀 이용 시 주의해주세요.',
            style: TextStyle(
              fontSize: screenHeight * 0.033,
            ),
          ),
        ),
      ], // 아이콘 색상 설정
    );
  }
}

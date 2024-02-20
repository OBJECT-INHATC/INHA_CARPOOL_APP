import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

/// 학생, 교직원 버튼
class ChangeProfessorButton extends StatelessWidget {
  final String isProfessorText;
  final bool isProfessor;
  final Function() onPressed;

  const ChangeProfessorButton({
    super.key,
    required this.isProfessorText,
    required this.isProfessor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Text(
            isProfessorText,
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: width * 0.035,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              decorationColor: Colors.grey[600],
            ),
            textAlign: TextAlign.end,
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: width * 0.037,
            color: Colors.grey[600],
          ),
        ],
      ),
    ).pOnly(right: width * 0.1);
  }
}

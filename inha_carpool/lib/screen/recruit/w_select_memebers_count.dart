import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

/// 인원수 선택 위젯
class LimitSelectorWidget extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final Function(String) onOptionSelected;

  const LimitSelectorWidget({super.key,
    required this.options,
    required this.selectedValue,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((option) {
        return Container(
          width: context.width(0.24),
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: TextButton(
            onPressed: () => onOptionSelected(option),
            style: TextButton.styleFrom(
              backgroundColor:
              selectedValue == option ? Colors.blue[200] : Colors.grey[300],
            ),
            child: Text(
              option,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
        );
      }).toList(),
    );
  }
}

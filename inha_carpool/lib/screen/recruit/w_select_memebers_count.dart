import 'package:flutter/material.dart';

class LimitSelectorWidget extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final Function(String) onOptionSelected;

  LimitSelectorWidget({
    required this.options,
    required this.selectedValue,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: TextButton(
            onPressed: () => onOptionSelected(option),
            style: TextButton.styleFrom(
              backgroundColor:
              selectedValue == option ? Colors.lightBlue : Colors.grey,
            ),
            child: Text(
              option,
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
        );
      }).toList(),
    );
  }
}

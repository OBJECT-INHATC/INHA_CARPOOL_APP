import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class GenderSelectorWidget extends StatefulWidget {
  final String selectedGender;
  final Function(String) onGenderSelected;

  const GenderSelectorWidget({super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  _GenderSelectorWidgetState createState() => _GenderSelectorWidgetState();
}

class _GenderSelectorWidgetState extends State<GenderSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: '성별'.text.size(20).bold.align(TextAlign.left).make(),
        ),
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: TextButton(
                  onPressed: () {
                    widget.onGenderSelected('남자');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: widget.selectedGender == '남자'
                        ? Colors.lightBlue
                        : Colors.grey,
                  ),
                  child: '남자'.text.white.size(17).make(),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                child: TextButton(
                  onPressed: () {
                    widget.onGenderSelected('여자');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: widget.selectedGender == '여자'
                        ? Colors.lightBlue
                        : Colors.grey,
                  ),
                  child: '여자'.text.white.size(17).make(),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: TextButton(
            onPressed: () {
              widget.onGenderSelected('무관');
            },
            style: TextButton.styleFrom(
              backgroundColor: widget.selectedGender == '무관'
                  ? Colors.lightBlue
                  : Colors.grey,
            ),
            child: '무관'.text.white.size(17).make(),
          ),
        ),
      ],
    );
  }
}

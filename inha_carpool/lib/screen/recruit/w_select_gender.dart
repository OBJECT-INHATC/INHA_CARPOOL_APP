import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';

class GenderSelectorWidget extends StatefulWidget {
  final String selectedGender;
  final Function(String) onGenderSelected;

  GenderSelectorWidget({
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
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: '성별'.text.size(25).align(TextAlign.left).make(),
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(30, 0, 12, 0),
              child: TextButton(
                onPressed: () {
                  widget.onGenderSelected('남자');
                },
                style: TextButton.styleFrom(
                  backgroundColor: widget.selectedGender == '남자'
                      ? Colors.lightBlue
                      : Colors.grey,
                ),
                child:
                '남자'.text.white.size(17).make(),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
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
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: TextButton(
            onPressed: () {
              widget.onGenderSelected('무관');
            },
            style: TextButton.styleFrom(
              backgroundColor: widget.selectedGender == '무관'
                  ? Colors.lightBlue
                  : Colors.grey,
            ),
            child:
            '무관'.text.white.size(17).make(),
          ),
        ),
      ],
    );
  }
}

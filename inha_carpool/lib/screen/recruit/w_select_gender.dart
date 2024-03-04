import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';


/// 성별 선택 위젯
class GenderSelectorWidget extends StatefulWidget {
  final String selectedGender;
  final String gender;
  final Function(String) onGenderSelected;


  const GenderSelectorWidget({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
    required this.gender,
  });

  @override
  GenderSelectorWidgetState createState() => GenderSelectorWidgetState();
}

class GenderSelectorWidgetState extends State<GenderSelectorWidget> {

  final String anyone = '무관';


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: '성별'.text.size(16).bold.align(TextAlign.left).make(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.width(0.4),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextButton(
                onPressed: () {
                  widget.onGenderSelected(widget.gender);
                },
                style: TextButton.styleFrom(
                  backgroundColor: widget.selectedGender == widget.gender
                      ? Colors.blue[200]
                      : Colors.grey[300],
                ),
                child: '${widget.gender}만'.text.white.size(16).make(),
              ),
            ),
            Container(
              width: context.width(0.4),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextButton(
                onPressed: () {
                  widget.onGenderSelected(anyone);
                },
                style: TextButton.styleFrom(
                  backgroundColor: widget.selectedGender == anyone
                      ? Colors.blue[200]
                      : Colors.grey[300],
                ),
                child: anyone.text.white.size(16).make(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

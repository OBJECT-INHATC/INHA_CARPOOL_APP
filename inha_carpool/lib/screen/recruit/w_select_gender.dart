import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  _GenderSelectorWidgetState createState() => _GenderSelectorWidgetState();
}

class _GenderSelectorWidgetState extends State<GenderSelectorWidget> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

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
                  widget.onGenderSelected('무관');
                },
                style: TextButton.styleFrom(
                  backgroundColor: widget.selectedGender == '무관'
                      ? Colors.blue[200]
                      : Colors.grey[300],
                ),
                child: '무관'.text.white.size(16).make(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

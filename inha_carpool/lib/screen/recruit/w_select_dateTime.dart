import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inha_Carpool/common/common.dart';

/// 날짜/시간 선택 위젯
class DateTimePickerWidget extends StatefulWidget {
  final String label;
  final DateTime selectedDateTime;
  final Function(DateTime) onDateTimeChanged;

  const DateTimePickerWidget({
    super.key,
    required this.label,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
  });

  @override
  _DateTimePickerWidgetState createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  bool _isTimePicker = false;

  @override
  void initState() {
    if (widget.label == "시간") _isTimePicker = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: context.width(0.9),
                child: _isTimePicker
                    ? SizedBox(
                        height: 250,
                        child: CupertinoTheme(
                          data: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: widget.selectedDateTime,
                            onDateTimeChanged: (DateTime newTime) {
                              setState(() {
                                widget.onDateTimeChanged(newTime);
                              });
                            },
                          ),
                        ),
                      )
                    : CupertinoTheme(
                        data: const CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle:
                                TextStyle(color: Colors.black, fontSize: 17),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: widget.selectedDateTime,
                          minimumYear: DateTime.now().year,
                          maximumYear: DateTime.now().year,
                          onDateTimeChanged: (DateTime newDate) {
                            setState(() {
                              widget.onDateTimeChanged(newDate);
                            });
                          },
                        ),
                ),
              );
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          decoration: const BoxDecoration(
              border:
                  Border(right: BorderSide(color: Colors.grey, width: 0.5))),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 시간 선택 시 오전/오후 표시
              _isTimePicker
                  ? Text(
                      widget.selectedDateTime.hour > 12 ? '오후' : '오전',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      widget.selectedDateTime.year.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              // 시간 선택 시 시간 표시
              _isTimePicker
                  ? Text(
                      "${widget.selectedDateTime.hour > 12 ? (widget.selectedDateTime.hour - 12).toString().padLeft(2, '0') : widget.selectedDateTime.hour.toString().padLeft(2, '0')}:"
                      "${widget.selectedDateTime.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 27,
                      ),
                    )
                  : Text(
                      "${widget.selectedDateTime.month.toString().padLeft(2, '0')}."
                      "${widget.selectedDateTime.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 27,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

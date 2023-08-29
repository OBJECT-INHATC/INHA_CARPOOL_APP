import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DateTimePickerWidget extends StatefulWidget {
  final String label;
  final DateTime selectedDateTime;
  final Function(DateTime) onDateTimeChanged;

  DateTimePickerWidget({
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
          showModalBottomSheet(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 300,
                child: _isTimePicker
                    ? SizedBox(
                        height: 250,
                        child: CupertinoTheme(
                          data: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 20,
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
                                TextStyle(color: Colors.black, fontSize: 20),
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
                        )),
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
                    fontSize: 15,
                  ),
                ),
              ),
              _isTimePicker
                  ? Text(
                      widget.selectedDateTime.hour > 12 ? '오후' : '오전',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      widget.selectedDateTime.year.toString(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              _isTimePicker
                  ? Text(
                      "${widget.selectedDateTime.hour > 12 ? (widget.selectedDateTime.hour - 12).toString().padLeft(2, '0') : widget.selectedDateTime.hour.toString().padLeft(2, '0')}:"
                      "${widget.selectedDateTime.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 40,
                      ),
                    )
                  : Text(
                      "${widget.selectedDateTime.month.toString().padLeft(2, '0')}."
                      "${widget.selectedDateTime.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 40,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    if(widget.label == "시간") _isTimePicker = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 300,
                child: _isTimePicker
                    ? CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: widget.selectedDateTime,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      widget.onDateTimeChanged(newTime);
                    });
                  },
                )
                    : CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: widget.selectedDateTime,
                  minimumDate: DateTime(2023),
                  maximumDate: DateTime(2099),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      widget.onDateTimeChanged(newDate);
                    });
                  },
                ),
              );
            },
          );
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
          decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(color: Colors.grey, width: 0.5))),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              _isTimePicker
                  ? Text(
                widget.selectedDateTime.hour > 12 ? '오후' : '오전',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : Text(
                widget.selectedDateTime.year.toString(),
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _isTimePicker
                  ? Text(
                "${widget.selectedDateTime.hour > 12 ? (widget.selectedDateTime.hour - 12).toString().padLeft(2, '0') : widget.selectedDateTime.hour.toString().padLeft(2, '0')}:"
                    "${widget.selectedDateTime.minute.toString().padLeft(2, '0')}",
                style: TextStyle(
                  fontSize: 40,
                ),
              )
                  : Text(
                "${widget.selectedDateTime.month.toString().padLeft(2, '0')}."
                    "${widget.selectedDateTime.day.toString().padLeft(2, '0')}",
                style: TextStyle(
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

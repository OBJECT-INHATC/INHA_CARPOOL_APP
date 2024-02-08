import 'package:flutter/material.dart';

@immutable
class NoticeStateModel {
  final String carpoolContext;
  final String carpoolUri;
  final String mainContext;
  final String mainUri;

  const NoticeStateModel(
      {required this.carpoolContext,
      required this.carpoolUri,
      required this.mainContext,
      required this.mainUri});

  NoticeStateModel copyWith(
      {String? carpoolContext,
      String? carpoolUri,
      String? mainContext,
      String? mainUri}) {
    return NoticeStateModel(
        carpoolContext: carpoolContext ?? this.carpoolContext,
        carpoolUri: carpoolUri ?? this.carpoolUri,
        mainContext: mainContext ?? this.mainContext,
        mainUri: mainUri ?? this.mainUri);
  }
}


import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';


@immutable
class NoticeStateModel {
  final String context;
  final String uri;

  const NoticeStateModel({required this.context, required this.uri} );

  NoticeStateModel copyWith({String? context, String? uri}) {
    return NoticeStateModel(context: context ?? this.context, uri: uri ?? this.uri);
  }
}

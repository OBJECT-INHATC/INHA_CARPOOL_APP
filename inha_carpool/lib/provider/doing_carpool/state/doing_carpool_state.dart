
import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';


@immutable
class DoingCarPoolStateModel {
  final List<CarpoolModel> data;

  const DoingCarPoolStateModel({required this.data});

  DoingCarPoolStateModel copyWith({List<CarpoolModel>? data}) {
    return DoingCarPoolStateModel(data: data ?? this.data);
  }


}

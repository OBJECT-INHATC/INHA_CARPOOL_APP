
import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';


@immutable
class CarPoolStateModel {
  final List<CarpoolModel> data;

  const CarPoolStateModel({required this.data});

  CarPoolStateModel copyWith({List<CarpoolModel>? data}) {
    return CarPoolStateModel(data: data ?? this.data);
  }
}

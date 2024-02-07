
import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';


@immutable
class CarPoolState {
  final List<CarpoolModel> data;

  CarPoolState({required this.data});

  CarPoolState copyWith({List<CarpoolModel>? data}) {
    return CarPoolState(data: data ?? this.data);
  }
}

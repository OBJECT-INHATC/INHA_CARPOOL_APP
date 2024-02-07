import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/provider/carpool/repository/carpool_repository.dart';
import 'package:inha_Carpool/provider/carpool/state/carpool_state.dart';

import '../../common/models/m_member.dart';
/// 참여중인 카풀의 수를 관리하는 provider 0207 이상훈


class CarpoolCountProvider extends StateNotifier<CarPoolStateBase> {

  final Ref _ref;
  final CarpoolRepository repository;

  CarpoolCountProvider(this._ref, this.repository) : super(CarPoolStateLoading()) {
    _getList();
  }

  void _getList() {


  }


}
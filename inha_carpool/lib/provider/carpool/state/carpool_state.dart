
import 'package:inha_Carpool/common/models/m_carpool.dart';

abstract class CarPoolStateBase {}

class CarPoolStateLoading extends CarPoolStateBase {}

class CarPoolState extends CarPoolStateBase {
  final List<CarpoolModel> data;

  CarPoolState({required this.data});

  CarPoolState copyWith({List<CarpoolModel>? data}){
    return CarPoolState(data: data ?? this.data);
  }
}

class CarPoolStateError extends CarPoolStateBase {
  final String error;

  CarPoolStateError({required this.error});
}

// 새로고침 할때 사용, CursorPagination이 있을 떄
class CarPoolStateRefresh extends CarPoolState{
  CarPoolStateRefresh({required super.data});
}

// 리스트의 맨 아래로 내려서
// 추가 데이터를 요청하는 중
class CarPoolStateFetchingMore extends CarPoolState {
  CarPoolStateFetchingMore({required super.data});
}
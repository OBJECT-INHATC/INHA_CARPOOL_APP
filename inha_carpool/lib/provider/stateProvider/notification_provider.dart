
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// 알람을 받았는지 관리하는 provider  (알림 on/off 설정과 무관)
final isPushOnAlarm = StateProvider<bool>((ref) => false);





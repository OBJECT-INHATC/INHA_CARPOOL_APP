
import 'package:easy_localization/easy_localization.dart';

// DateTime 클래스를 확장하여 다양한 형식으로 포맷하는 기능을 추가한 확장(extension) 클래스

extension DateTimeExtension on DateTime {
  // 날짜를 'dd/MM/yyyy' 형식으로 포맷한 문자열 반환
  String get formattedDate => DateFormat('dd/MM/yyyy').format(this);

  String get formattedDateKo => DateFormat('yyyy년 mm월 dd일').format(this);

  String get formattedDateCarpool => DateFormat('yyyy-mm-dd').format(this);

  String get formattedDateMyCarpool => DateFormat('yy.MM.dd HH:mm').format(this);




  // 시간을 'HH:mm' 형식으로 포맷한 문자열 반환
  String get formattedTime => DateFormat('HH:mm').format(this);

  // 날짜와 시간을 'dd/MM/yyyy HH:mm' 형식으로 포맷한 문자열 반환
  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);
}
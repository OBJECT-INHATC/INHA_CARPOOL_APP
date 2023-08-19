import 'package:easy_localization/easy_localization.dart';

final decimalFormat = NumberFormat.decimalPattern("en");

extension IntExt on int {
  static int? safeParse(String? source) {
    if (source == null) return null;
    return int.tryParse(source);
  }

  String toComma() {
    return decimalFormat.format(this);
  }

  String get withPlusMinus {
    if (this > 0) {
      return "+$this";
    } else if (this < 0) {
      return "$this";
    } else {
      return "0";
    }
  }
}

//숫자 값의 3자리 씩 ','(콤마) 적용
extension DoubleExt on double {
  String toComma() {
    return decimalFormat.format(this);
  }

 /* double number = 1234567.89;

  String formatted = number.toComma();
  print(formatted); // 출력: 1,234,567.89*/
}

class location_handler {
  // 위도 경도를 제외한 주소의 값을 가져옴
  static String getStringBetweenUnderscores(String input) {
    final firstUnderscoreIndex = input.indexOf('_');
    if (firstUnderscoreIndex >= 0) {
      final remainingString =
          input.substring(firstUnderscoreIndex + 1); // 첫 번째 '_' 이후의 문자열을 가져옴
      final secondUnderscoreIndex = remainingString.indexOf('_');
      if (secondUnderscoreIndex >= 0) {
        final stringBetweenUnderscores = remainingString.substring(
            0, secondUnderscoreIndex); // 첫 번째 '_'와 두 번째 '_' 사이의 문자열을 가져옴
        return stringBetweenUnderscores;
      }
    }
    return ''; // 어떤 '_'도 찾지 못하거나 두 번째 '_' 이후에 문자열이 없을 경우 빈 문자열을 리턴
  }

  static double parseDoubleBeforeUnderscore(String input) {
    final indexOfUnderscore = input.indexOf('_');
    if (indexOfUnderscore >= 0) {
      final doublePart = input.substring(0, indexOfUnderscore);
      return double.tryParse(doublePart) ?? 0.0; // 문자열을 더블로 파싱하고 실패하면 0.0을 리턴
    }
    return 0.0; // '_'가 없을 경우에는 0.0을 리턴
  }

  static double getDoubleAfterSecondUnderscore(String input) {
    final firstUnderscoreIndex = input.indexOf('_');
    if (firstUnderscoreIndex >= 0) {
      final remainingString =
          input.substring(firstUnderscoreIndex + 1); // 첫 번째 '_' 이후의 문자열을 가져옴
      final secondUnderscoreIndex = remainingString.indexOf('_');
      if (secondUnderscoreIndex >= 0) {
        final doubleString = remainingString
            .substring(secondUnderscoreIndex + 1); // 두 번째 '_' 이후의 문자열을 가져옴
        return double.tryParse(doubleString) ??
            0.0; // 문자열을 더블로 변환하고 실패할 경우 0.0을 리턴
      }
    }
    return 0.0; // 어떤 '_'도 찾지 못하거나 두 번째 '_' 이후에 문자열이 없을 경우 0.0을 리턴
  }
}

/// Adds extensions to num (ie. int & double) to make creating durations simple:
/// num(즉, int 및 double)에 확장을 추가하여 간단하게 시간 간격을 생성할 수 있는 기능을 제공
///
/// ```
/// 200.ms // equivalent to Duration(milliseconds: 200)
/// 3.seconds // equivalent to Duration(milliseconds: 3000)
/// 1.5.days // equivalent to Duration(hours: 36)
/// ```

extension NumDurationExtension on num {
  // 마이크로초 간격을 나타내는 Duration 객체를 반환합니다.
  Duration get microseconds => Duration(microseconds: round());

  // 밀리초 간격을 나타내는 Duration 객체를 반환합니다.
  Duration get ms => (this * 1000).microseconds;

  // 밀리초 간격을 나타내는 Duration 객체를 반환합니다.
  Duration get milliseconds => (this * 1000).microseconds;

  // 초 간격을 나타내는 Duration 객체를 반환합니다.
  Duration get seconds => (this * 1000 * 1000).microseconds;

  // 분 간격을 나타내는 Duration 객체를 반환합니다.
  Duration get minutes => (this * 1000 * 1000 * 60).microseconds;

  // 시간 간격을 나타내는 Duration 객체를 반환합니다.
  Duration get hours => (this * 1000 * 1000 * 60 * 60).microseconds;

  // 일 간격을 나타내는 Duration 객체를 반환합니다.
  Duration get days => (this * 1000 * 1000 * 60 * 60 * 24).microseconds;
}

  // 확장(extension)을 이용한 예시
/*  Duration duration1 = 200.ms;
  Duration duration2 = 3.seconds;
  Duration duration3 = 1.5.days;

  print('Duration 1: $duration1'); // Duration 1: 0:00:00.200000
  print('Duration 2: $duration2'); // Duration 2: 0:00:03.000000
  print('Duration 3: $duration3'); // Duration 3: 1:12:00:00.000000*/

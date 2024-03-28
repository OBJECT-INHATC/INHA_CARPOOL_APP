// 비동기 처리 미적용
void printOrderMessage() {
  print('고객 주문을 기다리는 중...');
  var order = fetchUserOrder();
  print('고객 주문은: $order');
}

fetchUserOrder() {
  print("sdasdfsdf");
  return Future.delayed(const Duration(seconds: 8), () => '바닐라라떼');
}

void countSeconds(int s) {
  for (var i = 1; i <= s; i++) {
    Future.delayed(Duration(seconds: i), () => print(i));
  }
}

void main() {
  countSeconds(4);
  printOrderMessage();
}
/// main이 countseconds 함수와 printOrderMessage 함수를 실행.
/// 4초동안 프린트가 찍히면서 printOrderMessage 함수도 진행하게 됨.
/// 고객 주문을 기다리는 중... 이라는 프린트문이 출력되고 order에 fetchUserOrder 함수의 리턴값이 들어가야함
/// 다음 프린트문이 order의 값을 출력해야 하는데 fetchUserOrder 함수는 8초 후에 '바닐라라떼'라는 리턴 값을 반환해 줌
/// 프린트문이 order의 값을 알 수 없는데 실행은 되므로 order 값을 모른 채 출력
//
//비동기 처리 적용
//
// Future<void> printOrderMessage() async {
//   print('고객 주문을 기다리는 중...');
//   var order = await fetchUserOrder();
//   print('고객 주문은: $order');
// }
//
// Future<String> fetchUserOrder() {
//   return Future.delayed(const Duration(seconds: 8), () => '바닐라라떼');
// }
//
// void countSeconds(int s) {
//   for (var i = 1; i <= s; i++) {
//     Future.delayed(Duration(seconds: i), () => print(i));
//   }
// }
//
// void main() {
//   countSeconds(4);
//   printOrderMessage();
// }

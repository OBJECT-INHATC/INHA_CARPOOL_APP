
class DeletedRoomException implements Exception {
  final String message;

  DeletedRoomException(this.message);

  @override
  String toString() {
    return message;
  }
}

class MaxCapacityException implements Exception {
  final String message;

  MaxCapacityException(this.message);

  @override
  String toString() {
    return message;
  }
}
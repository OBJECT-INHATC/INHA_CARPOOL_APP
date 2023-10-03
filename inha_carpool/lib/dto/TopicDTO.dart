class TopicRequstDTO {
  final String uid;
  final String carId;

  TopicRequstDTO({
    required this.uid,
    required this.carId,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "carId": carId,
      };
}

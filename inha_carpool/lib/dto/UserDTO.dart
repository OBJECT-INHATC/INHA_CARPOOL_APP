class UserRequstDTO {
  final String uid;
  final String nickname;
  final String email;

  UserRequstDTO({
    required this.uid,
    required this.nickname,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'email': email,
    };
  }
}

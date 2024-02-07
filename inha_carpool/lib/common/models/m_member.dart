class MemberModel {
  final String? nickName;
  final String? userName;
  final String? uid;
  final String? gender;
  final String? email;

  MemberModel(
      {this.nickName, this.uid, this.gender, this.email, this.userName});


  //from Json
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      nickName: json['nickName'] as String,
      uid: json['uid'] as String,
      userName: json['userName'] as String,
      gender: json['gender'] as String,
      email: json['email'] as String,
    );
  }

  //toJson
  Map<String, dynamic> toJson() {
    return {
      'nickName': nickName,
      'uid': uid,
      'userName': userName,
      'gender': gender,
      'email': email,
    };
  }




}

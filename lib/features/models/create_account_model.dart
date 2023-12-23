import 'dart:convert';

import 'package:equatable/equatable.dart';

UserAccountModel userAccountModelFromJson(String str) =>
    UserAccountModel.fromJson(json.decode(str));

String userAccountModelToJson(UserAccountModel data) =>
    json.encode(data.toJson());

class UserAccountModel extends Equatable{
  UserAccountModel({
  this.uid,
  this.imageProfile,
  this.fullName,
  this.email,
  this.password,
  });

  String? uid;
  String? imageProfile;
  String? fullName;
  String? email;
  String? password;

  UserAccountModel copyWith({
    String? uid,
    String? imageProfile,
    String? fullName,
    String? email,
    String? password,
  }) =>
      UserAccountModel(
        uid: uid ?? this.uid,
        imageProfile: imageProfile ?? this.imageProfile,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  factory UserAccountModel.fromJson(Map<String, dynamic> json) =>
      UserAccountModel(
        uid: json["uid"],
        imageProfile: json["imageProfile"],
        fullName: json["fullName"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "imageProfile": imageProfile,
    "fullName": fullName,
    "email": email,
    "password": password,
  };

  @override
  List<Object?> get props => [
    uid,
    imageProfile,
    fullName,
    email,
    password,
  ];
}


// class Person {
//   String? uid;
//   String? imageProfile;
//   String? fullName;
//   String? email;
//   String? password;
//
//   Person({
//     this.uid,
//     this.imageProfile,
//     this.fullName,
//     this.email,
//     this.password,
// });
//
//   static Person fromDataSnapshot(DocumentSnapshot snapshot) {
//     var dataSnapshot = snapshot.data() as Map<String, dynamic>;
//
//     return Person(
//       uid: dataSnapshot["uid"],
//       imageProfile: dataSnapshot["imageProfile"],
//       fullName: dataSnapshot["fullName"],
//       email: dataSnapshot["email"],
//       password: dataSnapshot["password"],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "uid": uid,
//     "imageProfile": imageProfile,
//     "fullName": fullName,
//     "email": email,
//     "password": password,
//   };



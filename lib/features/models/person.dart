import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String? uid;
  String? imageProfile;
  String? fullName;
  String? email;
  String? password;

  Person({
    this.uid,
    this.imageProfile,
    this.fullName,
    this.email,
    this.password,
});

  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return Person(
      uid: dataSnapshot["uid"],
      imageProfile: dataSnapshot["imageProfile"],
      fullName: dataSnapshot["fullName"],
      email: dataSnapshot["email"],
      password: dataSnapshot["password"],
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "imageProfile": imageProfile,
    "fullName": fullName,
    "email": email,
    "password": password,
  };
}
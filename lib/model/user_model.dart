import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String name;
  final String photoUrl;
  final Timestamp userSince;
  final String suscription;
  final String selectedGender;
  final String analysisStyle;
  final String pin;
  final Timestamp pinCreatedAt;
  final bool pinCreated;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.userSince,
    required this.suscription,
    required this.selectedGender,
    required this.analysisStyle,
    required this.pin,
    required this.pinCreatedAt,
    required this.pinCreated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      userSince: json['userSince'],
      suscription: json['suscription'],
      selectedGender: json['selectedGender'],
      analysisStyle: json['analysisStyle'],
      pin: json['pin'],
      pinCreatedAt: json['pinCreatedAt'],
      pinCreated: json['pinCreated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'userSince': userSince,
      'suscription': suscription,
      'selectedGender': selectedGender,
      'analysisStyle': analysisStyle,
      'pin': pin,
      'pinCreatedAt': pinCreatedAt,
      'pinCreated': pinCreated,
    };
  }
}

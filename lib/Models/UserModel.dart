import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.id,
    this.officeId,
    this.hasCard,
    this.photo,
    required this.name,
    this.address,
    this.postcode,
    this.city,
    this.province,
    this.phoneNumber,
    required this.username,
    required this.email,
    this.password,
    required this.status,
    this.emailVerifiedAt,
    this.rememberToken,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  int? officeId;
  bool? hasCard;
  String? photo;
  String? name;
  String? address;
  String? postcode;
  String? city;
  String? province;
  String? phoneNumber;
  String? username;
  String? email;
  String? password;
  String? status;
  dynamic emailVerifiedAt;
  dynamic rememberToken;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"] != null ? _parseInt(json["id"]) : null,
        officeId: json["office_id"] != null ? _parseInt(json["office_id"]) : null,
        hasCard: json["has_card"] == true || json["has_card"] == 1,
        photo: json["photo"] ?? '',
        name: json["name"] ?? '',
        address: json["address"] ?? '',
        postcode: json["postcode"] ?? '',
        city: json["city"] ?? '',
        province: json["province"] ?? '',
        phoneNumber: json["phone_number"] ?? '',
        username: json["username"] ?? '',
        email: json["email"] ?? '',
        password: json["password"] ?? '',
        status: json["status"] ?? '',
        emailVerifiedAt: json["email_verified_at"] != null
            ? DateTime.tryParse(json["email_verified_at"].toString())
            : null,
        rememberToken: json["remember_token"],
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"].toString())
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "office_id": officeId,
        "has_card": hasCard == true ? 1 : 0,
        "photo": photo,
        "name": name,
        "address": address,
        "postcode": postcode,
        "city": city,
        "province": province,
        "phone_number": phoneNumber,
        "username": username,
        "email": email,
        "password": password,
        "status": status,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "remember_token": rememberToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  // Helper function to parse int from dynamic type
  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
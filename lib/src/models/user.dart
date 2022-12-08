import 'package:delivery_man_app/src/models/courier.dart';
import 'package:delivery_man_app/src/models/media.dart';

class User {
  late bool auth;
  String id;
  String name;
  String email;
  String phone;
  String token;
  String firebaseToken;
  String? password;
  Courier? courier;
  Media? picture;

  User({
    this.auth = false,  
    this.id = "",
    this.name = "",
    this.email = "",
    this.token = "",
    this.firebaseToken = "",
    this.phone = "",
  });

  User.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        name = jsonMap['name'] ?? '',
        email = jsonMap['email'] ?? '',
        phone = jsonMap['phone'] ?? '',
        token = jsonMap['api_token'] ?? '',
        firebaseToken = jsonMap['firebase_token'] ?? '',
        courier = jsonMap['courier'] != null
            ? Courier.fromJSON(jsonMap['courier'])
            : null,
        picture =
            jsonMap['media'] != null && (jsonMap['media'] as List).length > 0
                ? Media.fromJSON(jsonMap['media'][0])
                : null;

  Map<String, String> toJSON() {
    Map<String, String> json = {};
    json = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'api_token': token
    };
    if (password != null) {
      json.addAll({'password': password!});
    }
    return json;
  }

  Map toMapSocialRegister(String? photoUrl) {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    if (photoUrl != null) {
      map["photo_url"] = photoUrl;
    }
    return map;
  }
}

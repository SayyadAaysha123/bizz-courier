import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../helper/custom_trace.dart';
import '../helper/helper.dart';
import '../models/user.dart';

Future<User> login(String email, String password, bool rememberMe) async {
  var response = await http
      .post(Helper.getUri('driver/login', addApiToken: false),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
            'remember': "1"
          }))
      .timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return User.fromJSON(jsonDecode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(response.statusCode);
  }
}

Future<User> socialLogin(String securityToken) async {
  var response = await http
      .post(Helper.getUri('login/check', addApiToken: false),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'security_token': securityToken,
          }))
      .timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return User.fromJSON(jsonDecode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(response.statusCode);
  }
}

Future<bool> forgotPassword(String email) async {
  var response = await http
      .post(Helper.getUri('forgot-password', addApiToken: false),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{"email": email}))
      .timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return true;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(jsonDecode(response.body)['message'] ?? '');
  }
}

Future<User> verifyLogin(String apiToken) async {
  var response = await http
      .get(Helper.getUri('driver/login/verify'), headers: <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return User.fromJSON(jsonDecode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(response.statusCode);
  }
}

Future<User> register(String name, String email, String? phone, String password,
    {String? photo}) async {
  Map<String, String> body = {
    'name': name,
    'email': email,
    'password': password
  };
  if (phone != null) {
    body.addAll({
      'phone': phone,
    });
  }
  if (photo != null) {
    body.addAll({
      'photo_url': photo,
    });
  }
  var response = await http
      .post(Helper.getUri('driver/register', addApiToken: false),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body))
      .timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return User.fromJSON(jsonDecode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(jsonDecode(response.body)['errors'] ?? '');
  }
}

Future<User> profileUpdate(String name, String email, String phone,
    {String? password}) async {
  var response = await http
      .post(Helper.getUri('profile'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'name': name,
            'email': email,
            'phone': phone,
            'password': password
          }))
      .timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return User.fromJSON(jsonDecode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(jsonDecode(response.body)['errors'] ?? '');
  }
}

Future<User> profilePictureUpload(File image) async {
  final fileBytes = base64Encode(await image.readAsBytesSync());
  var response = await http
      .post(Helper.getUri('profile/picture'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'image': fileBytes}))
      .timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return User.fromJSON(jsonDecode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(jsonDecode(response.body)['errors'] ?? '');
  }
}

Future<bool> getDeliveryActive() async {
  var response =
      await http.get(Helper.getUri('active'), headers: <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  }).timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return jsonDecode(response.body)['data']['active'] ?? false;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(response.statusCode);
  }
}

Future<bool> updateDeliveryActive(bool active) async {
  var response = await http
      .patch(Helper.getUri('active'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{'active': active}))
      .timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return jsonDecode(response.body)['data']['active'] ?? false;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(response.body);
  }
}

Future<User> updateUserValuesSettings(
    bool usingAppPricing,
    double baseDistance,
    double additionalDistancePricing,
    double returnDistancePricing,
    double basePrice,
    double additionalStopTax) async {
  var response = await http
      .patch(Helper.getUri('settings'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'using_app_pricing': usingAppPricing,
            'base_distance': baseDistance,
            'additional_distance_pricing': additionalDistancePricing,
            'return_distance_pricing': returnDistancePricing,
            'base_price': basePrice,
            'additional_stop_tax': additionalStopTax,
          }))
      .timeout(const Duration(seconds: 15));
  print(jsonEncode(<String, dynamic>{
    'using_app_pricing': usingAppPricing,
    'base_distance': baseDistance,
    'additional_distance_pricing': additionalDistancePricing,
    'return_distance_pricing': returnDistancePricing,
    'base_price': basePrice,
    'additional_stop_tax': additionalStopTax,
  }));
  if (response.statusCode == HttpStatus.ok) {
    return User.fromJSON(jsonDecode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw jsonDecode(response.body)['message'] ?? response.statusCode;
  }
}

Future<void> updateLocation(LocationData location) async {
  var response = await http
      .patch(
        Helper.getUri('location'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'lat': location.latitude,
          'lng': location.longitude,
        }),
      )
      .timeout(const Duration(seconds: 15));

  if (response.statusCode != HttpStatus.ok) {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<bool> deleteAccount() async {
  var response = await http.delete(
    Helper.getUri('delete-account'),
    headers: <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  ).timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    return true;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body));
    throw Exception(jsonDecode(response.body)['message'] ?? '');
  }
}

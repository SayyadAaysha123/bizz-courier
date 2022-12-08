import 'dart:convert';
import 'dart:io';

import 'package:delivery_man_app/src/helper/helper.dart';
import 'package:delivery_man_app/src/models/user.dart';
import 'package:http/http.dart' as http;

Future<bool> updateFirebaseToken(User? user, String? firebaseToken) async {
  
  String jsonSend = jsonEncode(<String, String>{
    'firebase_token': firebaseToken ?? '',
  });
  var response = await http
      .post(Helper.getUri('notifications/update_token'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonSend)
      .timeout(const Duration(seconds: 15));
  
  if (response.statusCode == HttpStatus.ok) {
    return true;
  } else {
    return false;
  }
}

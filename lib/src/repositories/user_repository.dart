import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'setting_repository.dart';

const String userTableName = "user";

ValueNotifier<User> currentUser = ValueNotifier(User());

class UserRepository {
  UserRepository();

  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    FlutterSecureStorage storage = const FlutterSecureStorage();

    if (prefs.getBool('first_run') ?? true) {
      prefs.setBool('first_run', false);
    }

    String userString = await storage.read(key: 'current_user') ?? '';

    if (userString.isNotEmpty && !currentUser.value.auth) {
      currentUser.value = User.fromJSON(json.decode(userString));
      currentUser.value.auth = true;
    } else {
      currentUser.value.auth = false;
    }
    return currentUser.value;
  }

  Future<void> setUser(User user) async {
    const storage = FlutterSecureStorage();
    if (user.courier?.usingAppPricing ??
        false || user.courier?.baseDistance == null) {
      user.courier?.baseDistance = setting.value.baseDistance;
    }
    if (user.courier?.usingAppPricing ??
        false || user.courier?.additionalStopTax == null) {
      user.courier?.additionalStopTax = setting.value.additionalStopTax;
    }
    if (user.courier?.usingAppPricing ??
        false || user.courier?.basePrice == null) {
      user.courier?.basePrice = setting.value.basePrice;
    }
    if (user.courier?.usingAppPricing ??
        false || user.courier?.additionalDistancePricing == null) {
      user.courier?.additionalDistancePricing =
          setting.value.additionalDistancePricing;
    }

    await storage.write(key: 'current_user', value: jsonEncode(user.toJSON()));
    user.auth = true;
    currentUser.value = user;
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();

    if (await storage.containsKey(key: 'current_user')) {
      var userString = await storage.read(key: 'current_user');
      if (userString != null) {
        currentUser.value = User.fromJSON(json.decode(userString.toString()));
      }
    }

    await storage.delete(key: 'current_user');
    currentUser.value = User();
  }

  Future<void> setActiveStatus(bool active) async {
    currentUser.value.courier?.active = active;
  }

  Future<void> updateValuesSettings(User user) async {
    const storage = FlutterSecureStorage();
    if (user.courier?.usingAppPricing ??
        false || user.courier?.baseDistance == null) {
      user.courier?.baseDistance = setting.value.baseDistance;
    }
    if (user.courier?.usingAppPricing ??
        false || user.courier?.additionalStopTax == null) {
      user.courier?.additionalStopTax = setting.value.additionalStopTax;
    }
    if (user.courier?.usingAppPricing ??
        false || user.courier?.basePrice == null) {
      user.courier?.basePrice = setting.value.basePrice;
    }
    if (user.courier?.usingAppPricing ??
        false || user.courier?.additionalDistancePricing == null) {
      user.courier?.additionalDistancePricing =
          setting.value.additionalDistancePricing;
    }
    if (user.courier?.usingAppPricing ??
        false || user.courier?.returnDistancePricing == null) {
      user.courier?.returnDistancePricing = setting.value.returnDistancePricing;
    }

    currentUser.value.courier?.baseDistance = user.courier?.baseDistance;
    currentUser.value.courier?.additionalStopTax =
        user.courier?.additionalStopTax;
    currentUser.value.courier?.basePrice = user.courier?.basePrice;
    currentUser.value.courier?.additionalDistancePricing =
        user.courier?.additionalDistancePricing;
    currentUser.value.courier?.returnDistancePricing =
        user.courier?.returnDistancePricing;
    await storage.write(
        key: 'current_user', value: jsonEncode(currentUser.value.toJSON()));
  }
}

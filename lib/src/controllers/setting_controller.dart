import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:delivery_man_app/src/models/setting.dart';
import 'package:delivery_man_app/src/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/custom_trace.dart';
import '../services/setting_service.dart';

class SettingController extends ControllerMVC {
  SettingController({bool doInitSettings: false}) {
    if (doInitSettings) {
      initSettings();
    }
  }

  Future<void> doGetSettings() async {
    await getSettings().then((Setting _setting) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', json.encode(_setting.toJSON()));
      setting.value = _setting;
      AdaptiveTheme.of(state!.context).setTheme(
        light: ThemeData(
          primaryColor: _setting.mainColor ?? Color(0xFF007FF4),
          highlightColor: _setting.highlightColor ?? Colors.white,
          scaffoldBackgroundColor:
              _setting.backgroundColor ?? const Color(0xFFF4F7FC),
          backgroundColor: _setting.backgroundColor ?? const Color(0xFFF4F7FC),
          colorScheme: const ColorScheme.light().copyWith(
            secondary: _setting.secondaryColor ?? Colors.black,
            secondaryContainer: _setting.secondaryColor ?? Colors.white,
            primary: _setting.mainColor ?? Color(0xFF007FF4),
          ),
        ),
        dark: ThemeData(
          primaryColor: _setting.mainColorDark ?? const Color(0xFFEEEEEE),
          highlightColor:
              _setting.highlightColorDark ?? const Color(0xFF252525),
          scaffoldBackgroundColor:
              _setting.backgroundColorDark ?? const Color(0xFF343636),
          backgroundColor:
              _setting.backgroundColorDark ?? const Color(0xFF343636),
          colorScheme: const ColorScheme.dark().copyWith(
            secondary: _setting.secondaryColorDark ?? Colors.white,
            secondaryContainer: _setting.secondaryColorDark ?? Colors.white,
            primary: _setting.mainColorDark ?? Color(0xFF007FF4),
          ),
        ),
      );
    }).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw 'Erro ao buscar configurações';
    });
  }
}

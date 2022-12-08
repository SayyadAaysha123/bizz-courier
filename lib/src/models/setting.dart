import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:delivery_man_app/src/models/distance_unit_enum.dart';
import 'package:flutter/material.dart';

class Setting {
  String appName;
  Color? mainColor;
  Color? secondaryColor;
  Color? highlightColor;
  Color? backgroundColor;
  Color? mainColorDark;
  Color? secondaryColorDark;
  Color? highlightColorDark;
  Color? backgroundColorDark;
  DistanceUnitEnum distanceUnit;
  AdaptiveThemeMode theme;
  double basePrice;
  double baseDistance;
  double additionalDistancePricing;
  double returnDistancePricing;
  double additionalStopTax;
  bool enableTermsOfService;
  String termsOfService;
  bool enablePrivacyPolicy;
  String privacyPolicy;
  bool allowCustomOrderValues;
  Locale locale;

  String currency;
  bool currencyRight;
  String currencySymbol;

  bool facebookEnabled = false;
  bool googleEnabled = false;
  bool twitterEnabled = false;

  Setting({
    this.appName = '',
    this.distanceUnit = DistanceUnitEnum.kilometer,
    this.theme = AdaptiveThemeMode.light,
    this.basePrice = 0.00,
    this.baseDistance = 0.00,
    this.additionalDistancePricing = 0.00,
    this.returnDistancePricing = 0.00,
    this.additionalStopTax = 0.00,
    this.enableTermsOfService = false,
    this.termsOfService = '',
    this.enablePrivacyPolicy = false,
    this.privacyPolicy = '',
    this.allowCustomOrderValues = true,
    this.currency = "",
    this.currencyRight = false,
    this.currencySymbol = "",
    this.facebookEnabled = false,
    this.googleEnabled = false,
    this.twitterEnabled = false,
    this.locale = const Locale('en'),
  });

  Setting.fromJSON(Map<String, dynamic> jsonMap)
      : appName = jsonMap['app_name'] ?? '',
        mainColor = jsonMap['main_color'] != null && jsonMap['main_color'] != ''
            ? Color(int.parse(jsonMap['main_color'].replaceAll('#', '0xff')))
            : null,
        secondaryColor = jsonMap['secondary_color'] != null &&
                jsonMap['secondary_color'] != ''
            ? Color(
                int.parse(jsonMap['secondary_color'].replaceAll('#', '0xff')))
            : null,
        highlightColor = jsonMap['highlight_color'] != null &&
                jsonMap['highlight_color'] != ''
            ? Color(
                int.parse(jsonMap['highlight_color'].replaceAll('#', '0xff')))
            : null,
        backgroundColor = jsonMap['background_color'] != null &&
                jsonMap['background_color'] != ''
            ? Color(
                int.parse(jsonMap['background_color'].replaceAll('#', '0xff')))
            : null,
        mainColorDark = jsonMap['main_color_dark_theme'] != null &&
                jsonMap['main_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['main_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        secondaryColorDark = jsonMap['secondary_color_dark_theme'] != null &&
                jsonMap['secondary_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['secondary_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        highlightColorDark = jsonMap['highlight_color_dark_theme'] != null &&
                jsonMap['highlight_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['highlight_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        backgroundColorDark = jsonMap['background_color_dark_theme'] != null &&
                jsonMap['background_color_dark_theme'] != ''
            ? Color(int.parse(
                jsonMap['background_color_dark_theme'].replaceAll('#', '0xff')))
            : null,
        distanceUnit =
            DistanceUnitEnumHelper.enumFromString(jsonMap['distance_unit']),
        theme = AdaptiveThemeMode.light,
        locale = Locale(
          jsonMap['locale'] ?? 'en',
          jsonMap['locale_region'],
        ),
        enableTermsOfService = jsonMap['enable_terms_of_service'] == true ||
            jsonMap['enable_terms_of_service'] == "1",
        termsOfService = jsonMap['terms_of_service'] ?? '',
        enablePrivacyPolicy = jsonMap['enable_privacy_policy'] == true ||
            jsonMap['enable_privacy_policy'] == "1",
        privacyPolicy = jsonMap['privacy_policy'] ?? '',
        basePrice = jsonMap['base_price'] != null
            ? double.parse(jsonMap['base_price'])
            : 0.00,
        baseDistance = jsonMap['base_distance'] != null
            ? double.parse(jsonMap['base_distance'])
            : 0.00,
        additionalDistancePricing =
            jsonMap['additional_distance_pricing'] != null
                ? double.parse(jsonMap['additional_distance_pricing'])
                : 0.00,
        returnDistancePricing = jsonMap['return_distance_pricing'] != null
            ? double.parse(jsonMap['return_distance_pricing'])
            : 0.00,
        additionalStopTax = jsonMap['additional_stop_tax'] != null
            ? double.parse(jsonMap['additional_stop_tax'])
            : 0.00,
        allowCustomOrderValues = jsonMap['allow_custom_order_values'] == true ||
            jsonMap['allow_custom_order_values'] == "1",
        currency = jsonMap['currency'] ?? 'USD',
        currencyRight = jsonMap['currency_right'] == true ||
            jsonMap['currency_right'] == "1",
        currencySymbol = jsonMap['currency_symbol'] ?? '\$',
        facebookEnabled =
            jsonMap['enable_facebook'] == true || jsonMap['enable_facebook'] == "1",
        googleEnabled = jsonMap['enable_google'] == true ||
            jsonMap['enable_google'] == "1",
        twitterEnabled = jsonMap['enable_twitter'] == true ||
            jsonMap['enable_twitter'] == "1";

  Map<String, dynamic> toJSON() {
    return {
      'termos_entregador': termsOfService,
      'base_price': basePrice,
      'base_distance': baseDistance,
      'additional_distance_pricing': additionalDistancePricing,
      'return_distance_pricing': returnDistancePricing,
      'additional_stop_tax': additionalStopTax,
    };
  }
}

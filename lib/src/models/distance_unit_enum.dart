import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DistanceUnitEnum { mile, kilometer }

class DistanceUnitEnumHelper {
  static DistanceUnitEnum enumFromString(String? enumString) {
    switch (enumString) {
      case 'km':
        return DistanceUnitEnum.kilometer;
      case 'mi':
        return DistanceUnitEnum.mile;
      default:
        return DistanceUnitEnum.kilometer;
    }
  }

  static String abbreviation(
      DistanceUnitEnum distanceUnitEnum, BuildContext context) {
    switch (distanceUnitEnum) {
      case DistanceUnitEnum.kilometer:
        return AppLocalizations.of(context)!.km;
      case DistanceUnitEnum.mile:
        return AppLocalizations.of(context)!.mi;
      default:
        return '-';
    }
  }

  static String description(
      DistanceUnitEnum distanceUnitEnum, BuildContext context) {
    switch (distanceUnitEnum) {
      case DistanceUnitEnum.kilometer:
        return AppLocalizations.of(context)!.kilometer;
      case DistanceUnitEnum.mile:
        return AppLocalizations.of(context)!.mile;
      default:
        return '-';
    }
  }
}

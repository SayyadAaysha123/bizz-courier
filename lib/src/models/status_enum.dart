import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum StatusEnum {
  pending,
  accepted,
  rejected,
  collected,
  delivered,
  cancelled,
  completed,
}

class StatusEnumHelper {
  static StatusEnum? enumFromString(String enumString) {
    switch (enumString) {
      case 'pending':
        return StatusEnum.pending;
      case 'accepted':
        return StatusEnum.accepted;
      case 'rejected':
        return StatusEnum.rejected;
      case 'collected':
        return StatusEnum.collected;
      case 'delivered':
        return StatusEnum.delivered;
      case 'cancelled':
        return StatusEnum.cancelled;
      case 'completed':
        return StatusEnum.completed;
      default:
        return null;
    }
  }


  static String description(StatusEnum? statusEnum, BuildContext context) {
    switch (statusEnum) {
      case StatusEnum.pending:
        return AppLocalizations.of(context)!.pending;
      case StatusEnum.accepted:
        return AppLocalizations.of(context)!.accepted;
      case StatusEnum.rejected:
        return AppLocalizations.of(context)!.rejected;
      case StatusEnum.collected:
        return AppLocalizations.of(context)!.collected;
      case StatusEnum.delivered:
        return AppLocalizations.of(context)!.delivered;
      case StatusEnum.cancelled:
        return AppLocalizations.of(context)!.cancelled;
      case StatusEnum.completed:
        return AppLocalizations.of(context)!.completed;
      default:
        return '-';
    }
  }
}

extension StatusEnumExtension on StatusEnum {
  String get originalName {
    switch (this) {
      case StatusEnum.pending:
        return 'pending';
      case StatusEnum.accepted:
        return 'accepted';
      case StatusEnum.rejected:
        return 'rejected';
      case StatusEnum.collected:
        return 'collected';
      case StatusEnum.delivered:
        return 'delivered';
      case StatusEnum.cancelled:
        return 'cancelled';
      case StatusEnum.completed:
        return 'completed';
    }
  }
}

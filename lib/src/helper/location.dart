import 'package:delivery_man_app/src/repositories/setting_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart'
    as permissionHandler;

class LocationHelper {
  static Future<LocationData> getLocation(BuildContext? context,
      {bool withDialogs = true, bool dialogsRequired = false}) async {
    Location location = new Location();

    if (!await hasLocationPermission(context,
        withDialogs: withDialogs, dialogsRequired: dialogsRequired)) {
      throw context != null
          ? AppLocalizations.of(context)!.noPermissions
          : 'No permissions';
    }
    if (!await location.isBackgroundModeEnabled()) {
      location.enableBackgroundMode(enable: true);
    }

    return await location.getLocation();
  }

  static Future<bool> hasLocationPermission(BuildContext? context,
      {bool withDialogs = true, bool dialogsRequired = false}) async {
    if (!await hasServiceEnabled(context,
            withDialogs: withDialogs, dialogsRequired: dialogsRequired) ||
        !await showLocationDialogInfo(context)) {
      return false;
    }
    permissionHandler.PermissionStatus status =
        await permissionHandler.Permission.locationAlways.request();
    if (status != permissionHandler.PermissionStatus.granted &&
        status != permissionHandler.PermissionStatus.limited) {
      if (withDialogs && context != null) {
        bool openSettings = false;
        await showDialog(
          barrierDismissible: !dialogsRequired,
          context: context,
          builder: (BuildContext context) => WillPopScope(
            onWillPop: () async => !dialogsRequired,
            child: CupertinoAlertDialog(
              title:
                  Text(AppLocalizations.of(context)!.acessLocationAllTheTime),
              content: Text(AppLocalizations.of(context)!
                  .allowAppAcessLocationAllTimesContinue),
              actions: <Widget>[
                if (!dialogsRequired)
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.goToSettings),
                  isDefaultAction: true,
                  onPressed: () async {
                    openSettings = true;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
        if (openSettings) {
          await permissionHandler.openAppSettings();
        }
      }
      return false;
    }
    return true;
  }

  static Future<bool> hasServiceEnabled(BuildContext? context,
      {bool withDialogs = true, bool dialogsRequired = false}) async {
    Location location = new Location();
    bool _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      if (withDialogs && context != null) {
        bool requestService = false;
        await showDialog(
          context: context,
          barrierDismissible: !dialogsRequired,
          builder: (BuildContext context) => WillPopScope(
            onWillPop: () async => !dialogsRequired,
            child: CupertinoAlertDialog(
              title: Text(AppLocalizations.of(context)!.locationRequired),
              content:
                  Text(AppLocalizations.of(context)!.enableLocationContinue),
              actions: <Widget>[
                if (!dialogsRequired)
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.activate),
                  isDefaultAction: true,
                  onPressed: () async {
                    requestService = true;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
        if (requestService) {
          return await location.requestService();
        }
      }
      return false;
    }
    return true;
  }

  static Future<bool> showLocationDialogInfo(BuildContext? context) async {
    permissionHandler.PermissionStatus status =
        await permissionHandler.Permission.locationAlways.status;
    if (status == permissionHandler.PermissionStatus.granted ||
        status == permissionHandler.PermissionStatus.limited ||
        context == null) {
      return true;
    }
    bool accepted = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: CupertinoAlertDialog(
          content: Text(
              AppLocalizations.of(context)!.appCollectsLocationEvenBackground(setting.value.appName)),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.disagree),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.agree),
              isDefaultAction: true,
              onPressed: () async {
                accepted = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    return accepted;
  }
}

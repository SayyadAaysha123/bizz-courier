import 'package:delivery_man_app/src/helper/location.dart';
import 'package:delivery_man_app/src/models/screen_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../controllers/user_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../repositories/user_repository.dart';
import 'custom_toast.dart';

class DeliveryAvailable extends StatefulWidget {
  final bool refreshOnStart;
  final Color? titleColor;
  const DeliveryAvailable(
      {Key? key, this.titleColor, this.refreshOnStart = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DeliveryAvailableState();
  }
}

class DeliveryAvailableState extends StateMVC<DeliveryAvailable> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late UserController _userCon;
  bool gettingPermisison = false;
  late FToast fToast;

  DeliveryAvailableState() : super(UserController()) {
    _userCon = controller as UserController;
    _userCon.scaffoldKey = _key;
  }

  @override
  void initState() {
    super.initState();
    if (widget.refreshOnStart) {
      refreshStatus();
    }
    fToast = FToast();
    fToast.init(context);
  }

  Future<void> refreshStatus() async {
    await _userCon.doGetDeliveryActive().catchError((error) {
      fToast.showToast(
          child: CustomToast(
            icon: const Icon(Icons.close, color: Colors.red),
            text: error.toString(),
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3));
    });
  }

  Future<void> updateStatus(bool active) async {
    if (!gettingPermisison) {
      gettingPermisison = true;
      if (active) {
        bool locationEnabled = await LocationHelper.hasLocationPermission(
                context,
                dialogsRequired: true)
            .catchError((error) {
          return false;
        });
        if (!locationEnabled) {
          gettingPermisison = false;
          return;
        }
      }
      await _userCon.doUpdateDeliveryActive(active).catchError((error) {
        fToast.showToast(
            child: CustomToast(
              icon: const Icon(Icons.close, color: Colors.red),
              text: error.toString(),
              actionText: AppLocalizations.of(context)!.connect,
              actionColor: Colors.green,
              action: () {
                Navigator.of(context).pushReplacementNamed(
                  '/Settings',
                  arguments: ScreenArgument({'index': 2}),
                );
              },
            ),
            gravity: ToastGravity.TOP,
            toastDuration: const Duration(seconds: 5));
      });
      gettingPermisison = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: _key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.receiveOrders,
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2,
                  color: widget.titleColor ?? Theme.of(context).primaryColor),
            ),
            SizedBox(width: 10),
            FlutterSwitch(
              activeColor: Colors.green,
              showOnOff: true,
              activeText: AppLocalizations.of(context)!.yes,
              inactiveText: AppLocalizations.of(context)!.no,
              valueFontSize: 18,
              value: currentUser.value.courier?.active ?? false,
              width: 80,
              height: 40,
              borderRadius: 30.0,
              switchBorder: Border.all(
                color: Color(0xFFD1D5DA),
                width: 2,
              ),
              toggleBorder: Border.all(
                color: Color(0xFFD1D5DA).withOpacity(.8),
                width: 1,
              ),
              onToggle: (isActive) async {
                await updateStatus(isActive);
              },
            ),
          ],
        )
      ],
    );
  }
}

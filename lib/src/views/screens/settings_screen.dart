import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:delivery_man_app/src/controllers/user_controller.dart';
import 'package:delivery_man_app/src/helper/helper.dart';
import 'package:delivery_man_app/src/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/distance_unit_enum.dart';
import '../../repositories/setting_repository.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_toast.dart';
import '../widgets/menu.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends StateMVC<SettingScreen> {
  late UserController _con;
  TextEditingController distanceController = TextEditingController();
  TextEditingController basePriceController = TextEditingController();
  TextEditingController additionalDistancePricingController =
      TextEditingController();
  TextEditingController returnDistancePricingController =
      TextEditingController();
  TextEditingController additionalStopTaxController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late FToast fToast;
  bool loading = false;
  late bool usingAppPricing = (!setting.value.allowCustomOrderValues ||
      (currentUser.value.courier?.usingAppPricing ?? true));
  double _baseDistance =
      currentUser.value.courier?.baseDistance ?? setting.value.baseDistance;
  double _basePrice =
      currentUser.value.courier?.basePrice ?? setting.value.basePrice;
  double _additionalDistancePricing =
      currentUser.value.courier?.additionalDistancePricing ??
          setting.value.additionalDistancePricing;
  double _returnDistancePricing =
      currentUser.value.courier?.returnDistancePricing ??
          setting.value.returnDistancePricing;
  double _additionalStopTax = currentUser.value.courier?.additionalStopTax ??
      setting.value.additionalStopTax;

  SettingScreenState() : super(UserController()) {
    _con = UserController();
  }

  @override
  void initState() {
    distanceController.text = Helper.doubleToString(_baseDistance);
    basePriceController.text = Helper.doubleToString(_basePrice);
    additionalDistancePricingController.text =
        Helper.doubleToString(_additionalDistancePricing);
    returnDistancePricingController.text =
        Helper.doubleToString(_returnDistancePricing);
    additionalStopTaxController.text =
        Helper.doubleToString(_additionalStopTax);
    super.initState();
    fToast = FToast();
    fToast.init(context);
    AdaptiveTheme.getThemeMode().then((theme) =>
        setState(() => setting.value.theme = theme ?? AdaptiveThemeMode.light));
  }

  bool isUsingBaseValue() {
    return currentUser.value.courier?.baseDistance ==
            setting.value.baseDistance &&
        currentUser.value.courier?.basePrice == setting.value.basePrice &&
        currentUser.value.courier?.additionalDistancePricing ==
            setting.value.additionalDistancePricing &&
        currentUser.value.courier?.returnDistancePricing ==
            setting.value.returnDistancePricing &&
        currentUser.value.courier?.additionalStopTax ==
            setting.value.additionalStopTax;
  }

  Future<void> saveSettings() async {
    fToast = FToast();
    fToast.init(context);
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      _formKey.currentState!.save();
      await _con
          .doUpdateValuesSettings(
              usingAppPricing,
              _baseDistance,
              _additionalDistancePricing,
              _returnDistancePricing,
              _basePrice,
              _additionalStopTax)
          .then((value) {
        fToast.removeCustomToast();
        fToast.showToast(
          child: CustomToast(
            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
            text: '${AppLocalizations.of(context)!.settingHaveBeenSaved}!',
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
      }).catchError((error) {
        fToast.removeCustomToast();
        fToast.showToast(
          child: CustomToast(
            backgroundColor: Colors.red,
            icon: Icon(Icons.close, color: Colors.white),
            text: error.toString(),
            textColor: Colors.white,
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(seconds: 3),
        );
      });
      setState(() {
        loading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: khulaSemiBold.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
        ),
        elevation: 1,
        shadowColor: Theme.of(context).primaryColor,
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          child: MenuWidget(),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 3, top: 3),
            child: RawScrollbar(
              thumbColor: Theme.of(context).hintColor,
              radius: Radius.circular(20),
              thickness: 4,
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  left: Dimensions.PADDING_SIZE_DEFAULT,
                  right: Dimensions.PADDING_SIZE_DEFAULT,
                  bottom: Dimensions.PADDING_SIZE_DEFAULT,
                ),
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [                  
                    SizedBox(
                      height: 5,
                    ),
                    ListTile(
                      horizontalTitleGap: 0,
                      title: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.theme,
                              style: rubikBold.copyWith(
                                  fontSize:
                                      Dimensions.FONT_SIZE_EXTRA_LARGE_2)),
                          const Spacer(),
                          FlutterSwitch(
                            width: 90,
                            height: 45,
                            toggleSize: 45.0,
                            value:
                                setting.value.theme == AdaptiveThemeMode.dark,
                            borderRadius: 30.0,
                            padding: 2.0,
                            activeToggleColor: Color(0xFF6E40C9),
                            inactiveToggleColor: Color(0xFF2F363D),
                            activeSwitchBorder: Border.all(
                              color: Color(0xFF3C1E70),
                              width: 5,
                            ),
                            inactiveSwitchBorder: Border.all(
                              color: Color(0xFFD1D5DA),
                              width: 5,
                            ),
                            activeColor: Color(0xFF271052),
                            inactiveColor: Colors.white,
                            activeIcon: Icon(
                              Icons.nightlight_round,
                              color: Color(0xFFF8E3A1),
                            ),
                            inactiveIcon: Icon(
                              Icons.wb_sunny,
                              color: Color(0xFFFFDF5D),
                            ),
                            onToggle: (isActive) {
                              if (isActive) {
                                AdaptiveTheme.of(context).setDark();
                                setState(() => setting.value.theme =
                                    AdaptiveThemeMode.dark);
                              } else {
                                AdaptiveTheme.of(context).setLight();
                                setState(() => setting.value.theme =
                                    AdaptiveThemeMode.light);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      height: Dimensions.PADDING_SIZE_SMALL,
                    ),
                    SizedBox(height: 10),
                    if (setting.value.allowCustomOrderValues)
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .configureDeliveryFeeValues,
                            textAlign: TextAlign.center,
                            style: rubikBold.copyWith(
                                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2),
                          ),
                          ListTile(
                            horizontalTitleGap: 0,
                            title: Row(
                              children: [
                                Text(
                                    AppLocalizations.of(context)!
                                        .useAppBaseValue,
                                    style: rubikBold.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_LARGE)),
                                const Spacer(),
                                FlutterSwitch(
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                  showOnOff: true,
                                  activeText: AppLocalizations.of(context)!.yes,
                                  inactiveText:
                                      AppLocalizations.of(context)!.no,
                                  valueFontSize: 14,
                                  value: usingAppPricing,
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
                                    if (isActive) {
                                      Alert(
                                        context: context,
                                        type: AlertType.warning,
                                        style: AlertStyle(
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          titleStyle: khulaBold.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: Dimensions
                                                  .FONT_SIZE_EXTRA_LARGE_2),
                                          descStyle: khulaSemiBold.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize:
                                                  Dimensions.FONT_SIZE_LARGE),
                                        ),
                                        title:
                                            '${AppLocalizations.of(context)!.attention}!'
                                                .toUpperCase(),
                                        desc: AppLocalizations.of(context)!
                                            .theValuesWillResetAppBase,
                                        buttons: [
                                          DialogButton(
                                            highlightColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(.2),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .continuee,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                usingAppPricing = isActive;
                                                if (isActive == true) {
                                                  distanceController.text =
                                                      Helper.doubleToString(
                                                          setting.value
                                                              .baseDistance);
                                                  additionalStopTaxController
                                                          .text =
                                                      Helper.doubleToString(
                                                          setting.value
                                                              .additionalStopTax);
                                                  basePriceController.text =
                                                      Helper.doubleToString(
                                                          setting
                                                              .value.basePrice);
                                                  additionalDistancePricingController
                                                          .text =
                                                      Helper.doubleToString(setting
                                                          .value
                                                          .additionalDistancePricing);
                                                  returnDistancePricingController
                                                          .text =
                                                      Helper.doubleToString(setting
                                                          .value
                                                          .returnDistancePricing);
                                                }
                                                Navigator.pop(context);
                                              });
                                            },
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          DialogButton(
                                            highlightColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(.2),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .cancel,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ],
                                      ).show();
                                    } else {
                                      setState(() {
                                        usingAppPricing = isActive;
                                        if (isActive == true) {
                                          distanceController.text =
                                              Helper.doubleToString(
                                                  setting.value.baseDistance);
                                          additionalStopTaxController.text =
                                              Helper.doubleToString(setting
                                                  .value.additionalStopTax);
                                          basePriceController.text =
                                              Helper.doubleToString(
                                                  setting.value.basePrice);
                                          additionalDistancePricingController
                                                  .text =
                                              Helper.doubleToString(setting
                                                  .value
                                                  .additionalDistancePricing);
                                          returnDistancePricingController.text =
                                              Helper.doubleToString(setting
                                                  .value.returnDistancePricing);
                                        }
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0, Dimensions.PADDING_SIZE_SMALL, 0, 0),
                            child: CustomTextFormField(
                              controller: basePriceController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\,?\d{0,2}'),
                                ),
                              ],
                              validateMode: AutovalidateMode.disabled,
                              color: Theme.of(context).highlightColor,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                              labelText:
                                  '${AppLocalizations.of(context)!.baseAmount}',
                              hintText: AppLocalizations.of(context)!.enterBaseAmount,
                              inputType:
                                  TextInputType.numberWithOptions(decimal: true),
                              onSave: (String value) {
                                _basePrice = Helper.StringTodouble(value);
                              },
                              isRequired: true,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterBaseAmount;
                                }
                                return null;
                              },
                              enabled: !usingAppPricing,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.amountInitiallyCharged,
                            style: rubikRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0, Dimensions.PADDING_SIZE_SMALL * 2, 0, 0),
                            child: CustomTextFormField(
                              controller: distanceController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\,?\d{0,2}'),
                                ),
                              ],
                              validateMode: AutovalidateMode.disabled,
                              color: Theme.of(context).highlightColor,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                              labelText: AppLocalizations.of(context)!.baseDistance,
                              hintText:
                                  AppLocalizations.of(context)!.enterBaseDistance,
                              inputType: TextInputType.number,
                              onSave: (String value) {
                                _baseDistance = Helper.StringTodouble(value);
                              },
                              isRequired: true,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterBaseDistance;
                                }
                                return null;
                              },
                              enabled: !usingAppPricing,
                            ),
                          ),
                          Text(
                              AppLocalizations.of(context)!
                                  .initialValueWithoutChargingAdditional(
                                DistanceUnitEnumHelper.abbreviation(
                                    setting.value.distanceUnit, context),
                              ),
                              style: rubikRegular.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_SMALL)),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0, Dimensions.PADDING_SIZE_SMALL * 2, 0, 0),
                            child: CustomTextFormField(
                              controller: additionalDistancePricingController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\,?\d{0,2}'),
                                ),
                              ],
                              validateMode: AutovalidateMode.disabled,
                              color: Theme.of(context).highlightColor,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                              labelText:
                                  '${AppLocalizations.of(context)!.distanceValue(
                                DistanceUnitEnumHelper.abbreviation(
                                    setting.value.distanceUnit, context),
                              )}',
                              hintText:
                                  AppLocalizations.of(context)!.enterDistanceValue(
                                DistanceUnitEnumHelper.abbreviation(
                                    setting.value.distanceUnit, context),
                              ),
                              inputType: TextInputType.number,
                              onSave: (String value) {
                                _additionalDistancePricing =
                                    Helper.StringTodouble(value);
                              },
                              isRequired: true,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterDistanceValue(
                                    DistanceUnitEnumHelper.description(
                                        setting.value.distanceUnit, context),
                                  );
                                }
                                return null;
                              },
                              enabled: !usingAppPricing,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.valueAdditionalBaseDistance(
                                DistanceUnitEnumHelper.description(
                                    setting.value.distanceUnit, context)),
                            style: rubikRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0, Dimensions.PADDING_SIZE_SMALL * 2, 0, 0),
                            child: CustomTextFormField(
                              controller: returnDistancePricingController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\,?\d{0,2}'),
                                ),
                              ],
                              validateMode: AutovalidateMode.disabled,
                              color: Theme.of(context).highlightColor,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                              labelText:
                                  '${AppLocalizations.of(context)!.returnDistance(DistanceUnitEnumHelper.abbreviation(setting.value.distanceUnit, context))}',
                              hintText:
                                  AppLocalizations.of(context)!.enterValueReturn(
                                DistanceUnitEnumHelper.description(
                                        setting.value.distanceUnit, context)
                                    .toLowerCase(),
                              ),
                              inputType: TextInputType.number,
                              onSave: (String value) {
                                _returnDistancePricing = Helper.StringTodouble(value);
                              },
                              isRequired: true,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterValueReturn(
                                    DistanceUnitEnumHelper.description(
                                            setting.value.distanceUnit, context)
                                        .toLowerCase(),
                                  );
                                }
                                return null;
                              },
                              enabled: !usingAppPricing,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.valueReturnPickupSite(
                              DistanceUnitEnumHelper.description(
                                      setting.value.distanceUnit, context)
                                  .toLowerCase(),
                            ),
                            style: rubikRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0, Dimensions.PADDING_SIZE_SMALL * 2, 0, 0),
                            child: CustomTextFormField(
                              controller: additionalStopTaxController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\,?\d{0,2}'),
                                ),
                              ],
                              validateMode: AutovalidateMode.disabled,
                              color: Theme.of(context).highlightColor,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                              ),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                              labelText:
                                  '${AppLocalizations.of(context)!.feePerStop}',
                              hintText: AppLocalizations.of(context)!.enterFeePerStop,
                              inputType: TextInputType.number,
                              onSave: (String value) {
                                _additionalStopTax = Helper.StringTodouble(value);
                              },
                              isRequired: true,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterFeePerStop;
                                }
                                return null;
                              },
                              enabled: !usingAppPricing,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.feeEachAdditionalStop,
                            style: rubikRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              left: 0,
                              right: 0,
                              bottom: Dimensions.PADDING_SIZE_LARGE * 2,
                              top: Dimensions.PADDING_SIZE_LARGE,
                            ),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                              ),
                              onPressed: loading
                                  ? null
                                  : () async {
                                      saveSettings();
                                    },
                              child: loading
                                  ? CircularProgressIndicator(
                                      color: Theme.of(context).highlightColor)
                                  : Text(
                                      AppLocalizations.of(context)!.saveValues,
                                      style: poppinsSemiBold.copyWith(
                                          color: Theme.of(context).highlightColor,
                                          fontSize:
                                              Dimensions.FONT_SIZE_EXTRA_LARGE),
                                    ),
                            ),
                          ),
                        ],
                      ),                                                        
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

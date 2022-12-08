import 'dart:async';

import 'package:delivery_man_app/src/models/address.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../models/order.dart';
import '../../views/widgets/order_address.dart';
import '../../views/widgets/order_buttons.dart';
import '../../views/widgets/order_details.dart';
import '../../models/status_enum.dart';
import '../../controllers/order_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../widgets/custom_toast.dart';

class OrderScreen extends StatefulWidget {
  final String orderId;
  final bool showButtons;
  const OrderScreen({Key? key, required this.orderId, this.showButtons = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OrderScreenState();
  }
}

class OrderScreenState extends StateMVC<OrderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late OrderController _con;
  int currentTab = 0;
  late FToast fToast;

  OrderScreenState() : super(OrderController()) {
    _con = controller as OrderController;
  }

  @override
  void initState() {
    getOrder();
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Future<void> getOrder() async {
    await _con.doGetOrder(widget.orderId).catchError((_error) {
      fToast.removeCustomToast();
      fToast.showToast(
        child: CustomToast(
          backgroundColor: Colors.red,
          icon: Icon(Icons.close, color: Colors.white),
          text: _error.toString(),
          textColor: Colors.white,
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: const Duration(seconds: 3),
      );
    });
  }

  Future<void> onButtonPressed(StatusEnum status, {String? addressId}) async {
    if (status == StatusEnum.cancelled || status == StatusEnum.rejected) {
      Alert(
        context: context,
        type: AlertType.warning,
        style: AlertStyle(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleStyle: khulaBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2),
          descStyle: khulaSemiBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.FONT_SIZE_LARGE),
        ),
        title: AppLocalizations.of(context)!.attention.toUpperCase(),
        desc:
            AppLocalizations.of(context)!.orderWillBeCanceledAmountRefundedSure,
        buttons: [
          DialogButton(
            highlightColor: Theme.of(context).primaryColor.withOpacity(.2),
            child: Text(
              AppLocalizations.of(context)!.no,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Theme.of(context).colorScheme.primary,
          ),
          DialogButton(
            highlightColor: Theme.of(context).primaryColor.withOpacity(.2),
            child: Text(
              AppLocalizations.of(context)!.yes,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _updateStatus(status);
            },
            color: Colors.red,
          )
        ],
      ).show();
    } else if (status == StatusEnum.delivered) {
      List<Address> enderecos = _con.order!.deliveryLocation
          .where((local) => local.delivered == false)
          .toList();
      Address selectedAddress = enderecos.first;
      if (enderecos.length > 1) {
        Alert(
            context: context,
            title: AppLocalizations.of(context)!.selectWhichAddressDeliveryMade,
            style: AlertStyle(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              titleStyle: khulaBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2),
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Column(
                  children: [
                    SizedBox(height: 20),
                    for (var _endereco in enderecos)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: RadioListTile<Address>(
                          visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity,
                            vertical: VisualDensity.minimumDensity,
                          ),
                          title: Text(
                            '${_endereco.name}',
                            style: khulaBold.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: Dimensions.FONT_SIZE_LARGE),
                          ),
                          value: _endereco,
                          groupValue: selectedAddress,
                          onChanged: (Address? _address) {
                            setState(() {
                              selectedAddress = _address!;
                            });
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            buttons: [
              DialogButton(
                highlightColor: Theme.of(context).primaryColor.withOpacity(.2),
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  Navigator.pop(context);
                  await _updateStatus(status, addressId: selectedAddress.id);
                },
                child: Text(
                  AppLocalizations.of(context)!.select,
                  style: poppinsSemiBold.copyWith(
                      color: Theme.of(context).highlightColor,
                      fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                ),
              )
            ]).show();
      } else {
        await _updateStatus(status, addressId: selectedAddress.id);
      }
    } else if (status == StatusEnum.completed) {
      Alert(
        context: context,
        type: AlertType.warning,
        style: AlertStyle(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleStyle: khulaBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE_2),
          descStyle: khulaSemiBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.FONT_SIZE_LARGE),
        ),
        title: AppLocalizations.of(context)!.attention.toUpperCase(),
        desc: AppLocalizations.of(context)!
            .orderRequiredReturningFinalizeOnlyAfterArrived,
        buttons: [
          DialogButton(
            highlightColor: Theme.of(context).primaryColor.withOpacity(.2),
            child: Text(
              AppLocalizations.of(context)!.finalize,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _updateStatus(status);
            },
            color: Theme.of(context).colorScheme.primary,
          ),
          DialogButton(
            highlightColor: Theme.of(context).primaryColor.withOpacity(.2),
            child: Text(
              "${AppLocalizations.of(context)!.returnn}",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Theme.of(context).hintColor,
          ),
        ],
      ).show();
    } else {
      await _updateStatus(status);
    }
  }

  Future<void> _updateStatus(StatusEnum status, {String? addressId}) async {
    setState(() => _con.updatingStatus = true);
    await _con
        .doUpdateOrderStatus(_con.order!.id, status, addressId)
        .catchError((_error) {
      fToast.removeCustomToast();
      fToast.showToast(
        child: CustomToast(
          backgroundColor: Colors.red,
          icon: Icon(Icons.close, color: Colors.white),
          text: _error.toString(),
          textColor: Colors.white,
        ),
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(seconds: 3),
      );
    }).then((Order order) {
      fToast.removeCustomToast();
      fToast.showToast(
        child: CustomToast(
          icon: Icon(Icons.check_circle_outline, color: Colors.green),
          text: status == StatusEnum.delivered &&
                  order.deliveryLocation
                      .where((local) => local.delivered == false)
                      .isNotEmpty
              ? AppLocalizations.of(context)!.deliveryConfirmedSelectedAddress
              : '${AppLocalizations.of(context)!.orderMarkedAs} ${StatusEnumHelper.description(order.orderStatus, context)}!',
        ),
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(seconds: 7),
      );
    });
    setState(() => _con.updatingStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _con.updatingStatus ? false : true,
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: _con.order == null || !widget.showButtons
            ? SizedBox()
            : OrderButtonsWidget(
                order: _con.order!,
                loading: _con.updatingStatus,
                onButtonPressed: (StatusEnum status, {String? addressId}) =>
                    onButtonPressed(status, addressId: addressId),
              ),
        appBar: AppBar(
          title: RichText(
            text: _con.order != null
                ? TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            '${AppLocalizations.of(context)!.order} #${_con.order!.id} - ',
                        style: khulaSemiBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_LARGE,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      TextSpan(
                        text: StatusEnumHelper.description(
                            _con.order!.orderStatus, context),
                        style: khulaBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_LARGE,
                            color: Theme.of(context).colorScheme.primary),
                      )
                    ],
                  )
                : const TextSpan(),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              if (!_con.updatingStatus) {
                Navigator.of(context).pop();
              }
            },
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: _con.loading
            ? const Center(child: CircularProgressIndicator())
            : _con.order == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.orderNotFound,
                        style: khulaBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: Dimensions.PADDING_SIZE_LARGE,
                          left: Dimensions.PADDING_SIZE_LARGE,
                          right: Dimensions.PADDING_SIZE_LARGE,
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
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton.icon(
                          onPressed: () async {
                            getOrder();
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).highlightColor,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.tryAgain,
                            style: poppinsSemiBold.copyWith(
                                color: Theme.of(context).highlightColor,
                                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      DefaultTabController(
                        initialIndex: currentTab,
                        length: 2,
                        child: Expanded(
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.4),
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: TabBar(
                                  onTap: (int tabIndex) {
                                    currentTab = tabIndex;
                                  },
                                  indicatorColor:
                                      Theme.of(context).primaryColor,
                                  labelColor: Theme.of(context).primaryColor,
                                  tabs: <Widget>[
                                    SizedBox(
                                      height: 60,
                                      child: Tab(
                                        icon: const Icon(
                                            FontAwesomeIcons.circleInfo,
                                            size: 20),
                                        iconMargin:
                                            const EdgeInsets.only(bottom: 5),
                                        text: AppLocalizations.of(context)!
                                            .details,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 60,
                                      child: Tab(
                                        icon: const Icon(
                                            FontAwesomeIcons.addressCard,
                                            size: 20),
                                        iconMargin:
                                            const EdgeInsets.only(bottom: 5),
                                        text: AppLocalizations.of(context)!
                                            .addresses,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: <Widget>[
                                    OrderDetailsWidget(order: _con.order!),
                                    OrderAddressWidget(order: _con.order!)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

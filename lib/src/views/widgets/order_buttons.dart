import 'package:auto_size_text/auto_size_text.dart';
import 'package:delivery_man_app/src/models/status_enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/order.dart';

class OrderButtonsWidget extends StatefulWidget {
  final Order order;
  final bool loading;
  final Function onButtonPressed;

  OrderButtonsWidget({
    Key? key,
    this.loading = false,
    required this.onButtonPressed,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderButtonsWidget> createState() => OrderButtonsWidgetState();
}

class OrderButtonsWidgetState extends State<OrderButtonsWidget> {
  Widget button(
      {double? width,
      required String text,
      required StatusEnum status,
      Color? color}) {
    return SizedBox(
      width: width ?? (MediaQuery.of(context).size.width - 40) / 2,
      child: TextButton(
        onPressed: () {
          widget.onButtonPressed(status);
        },
        style: TextButton.styleFrom(
            backgroundColor: color ?? Colors.green,
            minimumSize: Size(MediaQuery.of(context).size.width, 50),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
        child: AutoSizeText(
          text,
          textAlign: TextAlign.center,
          style: khulaBold.merge(TextStyle(
              color: Colors.white, fontSize: Dimensions.FONT_SIZE_LARGE)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.order.orderStatus! == StatusEnum.pending ||
          widget.order.orderStatus! == StatusEnum.accepted ||
          widget.order.orderStatus! == StatusEnum.collected,
      child: BottomAppBar(
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: (Colors.grey[400])!,
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: const Offset(0.0, -1.0),
              )
            ],
          ),
          child: widget.loading
              ? Center(child: CircularProgressIndicator())
              : widget.order.orderStatus! == StatusEnum.pending
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            button(
                                text: AppLocalizations.of(context)!.accept,
                                status: StatusEnum.accepted),
                            const SizedBox(width: 10),
                            button(
                                text: AppLocalizations.of(context)!.refuse,
                                status: StatusEnum.rejected,
                                color: Colors.red),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                  : widget.order.orderStatus! == StatusEnum.accepted
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                button(
                                    text: AppLocalizations.of(context)!
                                        .orderCollected,
                                    status: StatusEnum.collected),
                                const SizedBox(width: 10),
                                button(
                                    text: AppLocalizations.of(context)!
                                        .cancelOrder,
                                    status: StatusEnum.cancelled,
                                    color: Colors.red),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        )
                      : widget.order.orderStatus! == StatusEnum.collected
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    widget.order.deliveryLocation
                                                .where((local) =>
                                                    local.delivered == false)
                                                .length >
                                            0
                                        ? button(
                                            text: AppLocalizations.of(context)!
                                                .markDelivered,
                                            status: StatusEnum.delivered)
                                        : button(
                                            text: AppLocalizations.of(context)!
                                                .finalizeOrder,
                                            status: StatusEnum.completed),
                                    const SizedBox(width: 10),
                                    button(
                                        text: AppLocalizations.of(context)!
                                            .cancelOrder,
                                        status: StatusEnum.cancelled,
                                        color: Colors.red),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            )
                          : SizedBox(),
        ),
      ),
    );
  }
}

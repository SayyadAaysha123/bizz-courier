import 'package:auto_size_text/auto_size_text.dart';
import 'package:delivery_man_app/src/models/status_enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../helper/dimensions.dart';
import '../../helper/helper.dart';
import '../../helper/styles.dart';
import '../../models/distance_unit_enum.dart';

import '../../models/order.dart';
import '../../models/screen_argument.dart';
import '../../repositories/setting_repository.dart';

class OrderItemWidget extends StatefulWidget {
  final bool expanded;
  final bool showButtons;
  final Order order;
  final Function? loadPedidos;

  OrderItemWidget(
      {Key? key,
      this.expanded = false,
      this.showButtons = true,
      this.loadPedidos,
      required this.order})
      : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  late bool expanded;

  @override
  void initState() {
    expanded = widget.expanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: !widget.order.finalized ? 1 : 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 5,
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Card(
                  color: Theme.of(context).highlightColor,
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    onExpansionChanged: (bool _expanded) {
                      setState(() => expanded = _expanded);
                    },
                    initiallyExpanded: expanded,
                    title: Padding(
                      padding:
                          EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
                      child: Row(
                        children: [
                          Text(
                            Helper.formatDateTime(
                                widget.order.createdAt ?? DateTime.now()),
                            style: khulaBold.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                color: Theme.of(context).primaryColor),
                          ),
                          Expanded(
                            child: Transform.translate(
                              offset: const Offset(25, 0.0),
                              child: AutoSizeText(
                                '${widget.order.distance.toStringAsFixed(1)}${DistanceUnitEnumHelper.abbreviation(setting.value.distanceUnit, context)} - ${Helper.doubleToString((widget.order.amount), currency: true)}',
                                textAlign: TextAlign.right,
                                style: khulaBold.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.requestedBy}: ',
                                style: khulaBold.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    color: Theme.of(context).primaryColor),
                              ),
                              Expanded(
                                child: Transform.translate(
                                  offset: const Offset(25, 0.0),
                                  child: AutoSizeText(
                                    widget.order.user?.name.padRight(40) ?? '',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    minFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    maxFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    style: khulaBold.copyWith(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (widget.order.paymentGateway != null ||
                              widget.order.offlinePaymentMethod != null)
                            Row(
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.paymentMethod}: ',
                                  style: khulaBold.copyWith(
                                      fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                      color: Theme.of(context).primaryColor),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Transform.translate(
                                    offset: const Offset(25, 0.0),
                                    child: AutoSizeText(
                                      widget.order.paymentGateway != null
                                          ? widget.order.paymentGateway!
                                              .toString()
                                              .capitalize()
                                          : widget
                                              .order.offlinePaymentMethod!.name,
                                      textAlign: TextAlign.right,
                                      minFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                      maxFontSize: Dimensions.FONT_SIZE_DEFAULT,
                                      style: khulaBold.copyWith(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (!expanded)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Transform.translate(
                                  offset: const Offset(40, 0.0),
                                  child: ButtonBar(
                                    buttonPadding: EdgeInsets.zero,
                                    alignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await Navigator.pushNamed(
                                            context,
                                            '/Order',
                                            arguments: ScreenArgument({
                                              'orderId': widget.order.id,
                                              'showButtons': widget.showButtons
                                            }),
                                          ).then((value) {
                                            if (widget.loadPedidos != null) {
                                              widget.loadPedidos!();
                                            }
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .viewCompleteOrder,
                                              style: khulaSemiBold.merge(
                                                TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                              ),
                                            ),
                                            Icon(Icons.chevron_right,
                                                size: 25,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                    trailing: SizedBox(),
                    children: <Widget>[
                      if (expanded) SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${AppLocalizations.of(context)!.pickupAddress}:',
                              style: khulaBold.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Expanded(
                              child: Text(
                                (widget.order.pickupLocation?.name ?? '') +
                                    ' - ' +
                                    (widget.order.pickupLocation?.number ?? ''),
                                textAlign: TextAlign.right,
                                style: khulaRegular.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${AppLocalizations.of(context)!.deliveryAddress}:',
                              style: khulaBold.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor),
                            ),
                            Expanded(
                              child: Text(
                                '${widget.order.deliveryLocation.first.name + ' - ' + (widget.order.deliveryLocation.first.number)}${widget.order.deliveryLocation.length > 1 ? ' ${AppLocalizations.of(context)!.andMoreLocations(widget.order.deliveryLocation.length.toString())}' : ''}',
                                textAlign: TextAlign.right,
                                style: khulaRegular.copyWith(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ButtonBar(
                        buttonPadding: EdgeInsets.zero,
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/Order',
                                arguments: ScreenArgument({
                                  'orderId': widget.order.id,
                                  'showButtons': widget.showButtons
                                }),
                              ).then((value) {
                                if (widget.loadPedidos != null) {
                                  widget.loadPedidos!();
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!
                                        .viewCompleteOrder,
                                    style: khulaSemiBold.merge(TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary))),
                                Icon(Icons.chevron_right,
                                    size: 25,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 28,
          width: 140,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: widget.order.finalized
                  ? Colors.redAccent
                  : Theme.of(context).colorScheme.primary),
          alignment: AlignmentDirectional.center,
          child: Text(
            StatusEnumHelper.description(widget.order.orderStatus, context),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.caption!.merge(
                  TextStyle(height: 1, color: Colors.white),
                ),
          ),
        ),
      ],
    );
  }
}

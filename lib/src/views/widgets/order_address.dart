import 'package:auto_size_text/auto_size_text.dart';
import 'package:delivery_man_app/src/models/address.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/order.dart';

class OrderAddressWidget extends StatefulWidget {
  final Order order;

  OrderAddressWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderAddressWidget> createState() => _OrderAddressWidgetState();
}

class _OrderAddressWidgetState extends State<OrderAddressWidget> {
  void openAddress(Address endereco) {
    MapsLauncher.launchCoordinates(endereco.latitude, endereco.longitude,
        endereco.name + ' - ' + (endereco.number));
  }

  Widget generateDecoration(Widget conteudo) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            blurRadius: 5,
          )
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: conteudo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        SizedBox(height: 30),
        Text(
          AppLocalizations.of(context)!.clickOnAdressOpenInMap,
          textAlign: TextAlign.center,
          style: khulaBold.copyWith(
              fontSize: Dimensions.FONT_SIZE_LARGE,
              color: Theme.of(context).colorScheme.primary),
        ),
        SizedBox(height: 15),
        InkWell(
          onTap: () {
            openAddress(widget.order.pickupLocation!);
          },
          child: generateDecoration(
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
                vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
              ),
              title: Text(
                '${AppLocalizations.of(context)!.collect}:',
                style: khulaBold.copyWith(
                    fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                    color: Theme.of(context).colorScheme.primary),
              ),
              subtitle: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.FONT_SIZE_EXTRA_SMALL,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                ),
                child: AutoSizeText(
                  ((widget.order.pickupLocation?.formattedAddress) ??
                          AppLocalizations.of(context)!
                              .pickupAddressNotProvidedContactCustomer) +
                      ' - ' +
                      (widget.order.pickupLocation?.number ?? ''),
                  minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                  style: khulaRegular.copyWith(
                    fontSize: Dimensions.FONT_SIZE_LARGE,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        generateDecoration(
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.FONT_SIZE_EXTRA_SMALL,
              vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
            ),
            title: Text(
              '${AppLocalizations.of(context)!.deliveryAddresses}:',
              style: khulaBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                  color: Theme.of(context).colorScheme.primary),
            ),
            subtitle: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.order.deliveryLocation.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    openAddress(widget.order.deliveryLocation.elementAt(index));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: Dimensions.PADDING_SIZE_SMALL,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      border: Border.all(
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
                        vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
                      ),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.order.deliveryLocation
                                  .elementAt(index)
                                  .delivered
                              ? Icon(FontAwesomeIcons.check,
                                  color: Colors.green)
                              : Icon(FontAwesomeIcons.locationArrow),
                        ],
                      ),
                      iconColor: Theme.of(context).colorScheme.primary,
                      minLeadingWidth: 0,
                      title: AutoSizeText(
                        '${widget.order.deliveryLocation.elementAt(index).formattedAddress + ' - ' + (widget.order.deliveryLocation.elementAt(index).number)}',
                        style: khulaRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.order.returnRequired)
          InkWell(
            onTap: () {
              openAddress(widget.order.pickupLocation!);
            },
            child: generateDecoration(
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Dimensions.FONT_SIZE_DEFAULT + 1,
                  vertical: Dimensions.FONT_SIZE_EXTRA_SMALL / 2,
                ),
                title: Text(
                  '${AppLocalizations.of(context)!.returnCollectLocation}:',
                  style: khulaBold.copyWith(
                      fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                      color: Theme.of(context).colorScheme.primary),
                ),
                subtitle: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.FONT_SIZE_EXTRA_SMALL,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.55,
                  ),
                  child: AutoSizeText(
                    ((widget.order.pickupLocation?.formattedAddress) ??
                          AppLocalizations.of(context)!
                              .pickupAddressNotProvidedContactCustomer) +
                      ' - ' +
                      (widget.order.pickupLocation?.number ?? ''),
                    minFontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                    style: khulaRegular.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

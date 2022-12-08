import 'package:delivery_man_app/src/helper/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helper/dimensions.dart';
import '../../repositories/user_repository.dart';

class LinkShare extends StatefulWidget {
  final Color? titleColor;
  const LinkShare({Key? key, this.titleColor}) : super(key: key);

  @override
  State<LinkShare> createState() => _LinkShareState();
}

class _LinkShareState extends State<LinkShare> {
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.linkDeliveries,
          textAlign: TextAlign.start,
          style: khulaBold.copyWith(
              fontSize: Dimensions.FONT_SIZE_DEFAULT,
              color: widget.titleColor ?? Theme.of(context).primaryColor),
        ),
        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        Row(
          children: [
            InkWell(
              onTap: () async {
                if (!await launch(currentUser.value.courier?.link ?? '')) ;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75 - 85,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                    vertical: Dimensions.PADDING_SIZE_DEFAULT + 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    border: Border.all(color: Color(0xFFD1D5DA)),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: AutoSizeText(
                    currentUser.value.courier?.link ?? '',
                    minFontSize: 5,
                    maxLines: 1,
                    style: rubikMedium.copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(width: 5),
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                border: Border.all(color: Color(0xFFD1D5DA)),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: Dimensions.PADDING_SIZE_SMALL,
                ),
                onPressed: () async {
                  Share.share(currentUser.value.courier?.link ?? '');
                },
                icon: Icon(Icons.share),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

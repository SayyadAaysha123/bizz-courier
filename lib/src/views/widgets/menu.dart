import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_man_app/src/views/widgets/link_share.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../controllers/user_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/images.dart';
import '../../helper/styles.dart';
import '../../models/screen_argument.dart';
import '../../repositories/user_repository.dart';
import 'sign_out_confirmation_dialog.dart';

// ignore: must_be_immutable
class MenuWidget extends StatefulWidget {
  Function? onSwitchTab;
  MenuWidget({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MenuWidgetState();
  }
}

class MenuWidgetState extends StateMVC<MenuWidget> {
  late UserController _userCon;

  MenuWidgetState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !currentUser.value.auth
        ? SizedBox()
        : Scaffold(
            body: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(
                      '/Settings',
                      arguments: ScreenArgument({'index': 2}),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(top: 40, bottom: 15),
                    decoration:
                        BoxDecoration(color: Theme.of(context).backgroundColor),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 75,
                            width: 75,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Color(0xFFD1D5DA), width: 2)),
                            child: ClipOval(
                                child: currentUser.value.picture != null &&
                                        currentUser.value.picture!.id != ''
                                    ? CachedNetworkImage(
                                        progressIndicatorBuilder:
                                            (context, url, progress) => Center(
                                          child: CircularProgressIndicator(
                                            value: progress.progress,
                                          ),
                                        ),
                                        imageUrl:
                                            currentUser.value.picture!.url,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(Images.placeholderUser,
                                        color: Theme.of(context).primaryColor,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.scaleDown)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: Dimensions.PADDING_SIZE_SMALL),
                            child: Text(
                              currentUser.value.name,
                              style: TextStyle(
                                  fontSize: Dimensions.FONT_SIZE_LARGE,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: LinkShare(),
                          ),
                        ]),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!(0);
                          } else {
                            Navigator.of(context).pushReplacementNamed('/Home');
                          }
                        },
                        leading: Icon(FontAwesomeIcons.bagShopping,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.recentOrders,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE),
                        ),
                      ),
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(
                            '/Profile',
                          );
                        },
                        leading: Icon(FontAwesomeIcons.userLarge,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.profile,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE),
                        ),
                      ),
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(
                            '/Settings',
                            arguments: ScreenArgument({'index': 2}),
                          );
                        },
                        leading: Icon(FontAwesomeIcons.gear,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.settings,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE),
                        ),
                      ),
                      Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          height: 0),
                      ListTile(
                        horizontalTitleGap: 0,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => SignOutConfirmationDialog(
                                      onConfirmed: () async {
                                    await _userCon.doLogout();
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/Login', (route) => false);
                                    setState(() {});
                                  }));
                        },
                        leading: Icon(Icons.logout,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.logout,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

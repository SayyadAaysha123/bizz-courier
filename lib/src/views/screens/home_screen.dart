import 'dart:async';

import 'package:delivery_man_app/src/repositories/setting_repository.dart';
import 'package:delivery_man_app/src/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../controllers/user_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../widgets/menu.dart';
import 'recent_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  final int index;
  final bool saveLocation;
  const HomeScreen({Key? key, this.index = 0, this.saveLocation = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends StateMVC<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late UserController _con;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  Timer? _timer;

  HomeScreenState() : super(UserController()) {
    _con = controller as UserController;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setLocationListener();
    });
    super.initState();
  }

  Future<void> setLocationListener() async {
    if (widget.saveLocation) {
      await _con.doUpdateLocation().catchError((error) async {
        if (currentUser.value.courier?.active ?? false) {
          await _con.doUpdateDeliveryActive(false);
        }
        return;
      });
    }
    if (currentUser.value.courier?.active ?? false) {
      getLocationPeriodically();
    }
    currentUser.addListener(() {
      if (currentUser.value.courier?.active ?? false) {
        getLocationPeriodically();
      } else {
        if (_timer != null) {
          _timer!.cancel();
        }
      }
    });
  }

  Future<void> getLocationPeriodically() async {
    bool timerFinished = true;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = new Timer.periodic(Duration(seconds: 30), (Timer timer) async {
      if (timerFinished) {
        timerFinished = false;
        await _con
            .doUpdateLocation(dialogsRequired: true)
            .catchError((error) async {
          if (currentUser.value.courier?.active ?? false) {
            await _con.doUpdateDeliveryActive(false);
          }
          setState(() {
            currentUser.value.courier?.active;
          });
        }).whenComplete(() => timerFinished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          setting.value.appName,
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
      body: RecentOrdersScreen(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

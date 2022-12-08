import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../helper/dimensions.dart';
import '../widgets/delivery_available.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NavigationScreenState();
  }
}

class NavigationScreenState extends StateMVC<NavigationScreen> {
  final GlobalKey<DeliveryAvailableState> _deliveryAvailableState =
      GlobalKey<DeliveryAvailableState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> refresh() async {
    if (_deliveryAvailableState.currentState != null) {
      await _deliveryAvailableState.currentState!.refreshStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              DeliveryAvailable(key: _deliveryAvailableState),
            ],
          ),
        ),
      ),
    );
  }
}

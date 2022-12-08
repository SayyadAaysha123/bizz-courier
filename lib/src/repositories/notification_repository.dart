import 'dart:convert';
import 'dart:async';
import 'package:delivery_man_app/src/repositories/user_repository.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_man_app/src/models/user.dart';

import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:delivery_man_app/src/services/notification_service.dart'
    as NotificationService;

class NotificationRepository {
  NotificationRepository();

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    print("Handling a background message: ${message.messageId}");
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
        name: "courier", options: DefaultFirebaseOptions.currentPlatform);
    // android support only

    if (!FirebaseMessaging.instance.isSupported()) {
      return;
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();
    if (!(settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional)) {
      settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true, // Required to display a heads up notification
          badge: true,
          sound: true,
        );
        AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'high_importance_channel',
              title: message.notification?.title ?? '',
              body: message.notification?.body ?? '',
              bigPicture: message.notification?.android?.imageUrl),
        );
      });

      User user = await UserRepository().getCurrentUser();
      if (user.auth) {
        updateFcmToken(user);
      }
    }
  }

  Future<void> updateFcmToken(User currentUser) async {
    if (currentUser.auth && FirebaseMessaging.instance.isSupported()) {
      NotificationSettings notificationSetting =
          await FirebaseMessaging.instance.requestPermission();
      if (notificationSetting.authorizationStatus !=
              AuthorizationStatus.authorized &&
          notificationSetting.authorizationStatus !=
              AuthorizationStatus.provisional) {
        return;
      }
      String? _firebaseToken = await FirebaseMessaging.instance.getToken();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(_firebaseToken);
      print(currentUser.firebaseToken.toString());
      if (currentUser.firebaseToken.toString() != _firebaseToken) {
        //update the token on database
        await NotificationService.updateFirebaseToken(
                currentUser, _firebaseToken)
            .then((value) => () {
                  if (value) {
                    currentUser.firebaseToken = _firebaseToken ?? '';
                    prefs.setString(
                        'current_user', jsonEncode(currentUser.toJSON()));
                  }
                });
      }
    }
  }

  Future<void> removeFcmToken(User currentUser) async {
    String? _firebaseToken = "";
    await NotificationService.updateFirebaseToken(currentUser, _firebaseToken);
  }
}

import 'package:delivery_man_app/src/views/screens/auth/social_login.dart';
import 'package:delivery_man_app/src/views/screens/legal_terms.dart';
import 'package:flutter/material.dart';

import 'src/models/screen_argument.dart';
import 'src/views/screens/auth/forgot_password_screen.dart';
import 'src/views/screens/auth/login_screen.dart';
import 'src/views/screens/auth/sign_up_screen.dart';
import 'src/views/screens/chat.dart';
import 'src/views/screens/home_screen.dart';
import 'src/views/screens/profile_screen.dart';
import 'src/views/screens/settings_screen.dart';
import 'src/views/screens/order.dart';
import 'src/views/screens/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    ScreenArgument? argument;
    if (settings.arguments != null) {
      argument = settings.arguments as ScreenArgument;
    }
    switch (settings.name) {
      case '/Home':
        return MaterialPageRoute(
            builder: (context) => HomeScreen(
                saveLocation: argument?.arguments['saveLocation'] ?? false));
      case '/Profile':
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case '/Settings':
        return MaterialPageRoute(builder: (context) => SettingScreen());
      case '/Splash':
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case '/Login':
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case '/BasicSignup':
        return MaterialPageRoute(builder: (context) => const SignupScreen());
      case '/ForgotPassword':
        return MaterialPageRoute(
            builder: (context) => const ForgotPasswordScreen());
      case '/SocialLogin':
        return MaterialPageRoute(
          builder: (context) =>
              SocialLogin(argument!.arguments['socialNetwork']),
        );
      case '/Order':
        return MaterialPageRoute(
            builder: (context) => OrderScreen(
                orderId: argument!.arguments['orderId'] ?? '',
                showButtons: argument.arguments['showButtons'] ?? true));
      case '/Chat':
        return MaterialPageRoute(
          builder: (context) =>
              ChatScreen(argument!.arguments['orderId'] ?? ''),
        );
      case '/Termos':
        return MaterialPageRoute(builder: (context) => LegalTermsWidget());
      default:
        return MaterialPageRoute(
            builder: (context) =>
                const Scaffold(body: SafeArea(child: Text('Route Error'))));
    }
  }
}

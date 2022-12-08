import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:validators/validators.dart';

import '../../../controllers/user_controller.dart';
import '../../../helper/dimensions.dart';
import '../../../helper/images.dart';
import '../../../helper/styles.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ForgotPasswordScreenState();
  }
}

class ForgotPasswordScreenState extends StateMVC<ForgotPasswordScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  late UserController _userCon;
  late FToast fToast;
  String email = "";
  bool loading = false;

  ForgotPasswordScreenState() : super(UserController()) {
    _userCon = controller as UserController;
    _userCon.scaffoldKey = _key;
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Theme.of(context).primaryColor,
                        onPressed: loading
                            ? () {}
                            : () {
                                Navigator.of(context).pop();
                              },
                      ),
                    ),
                    Center(
                      child: Image.asset(Images.logo,
                          height: MediaQuery.of(context).size.height * 0.15),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CustomTextFormField(
                        hintText: AppLocalizations.of(context)!.email,
                        labelText: AppLocalizations.of(context)!.email,
                        inputType: TextInputType.emailAddress,
                        inputAction: TextInputAction.done,
                        onSave: (String value) {
                          email = value;
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "\u26A0 ${AppLocalizations.of(context)!.enterEmail}";
                          } else if (!isEmail(value)) {
                            return "\u26A0 ${AppLocalizations.of(context)!.enterValidEmail}";
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: Dimensions.PADDING_SIZE_DEFAULT,
                          top: Dimensions.PADDING_SIZE_EXTRA_LARGE,
                          right: Dimensions.PADDING_SIZE_DEFAULT),
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: const Offset(0, 1)),
                          ],
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: loading
                              ? () {}
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    setState(() => loading = true);

                                    await _userCon
                                        .doForgotPassword(email)
                                        .then((value) {
                                      setState(() => loading = false);
                                      fToast.showToast(
                                          child: CustomToast(
                                            icon: const Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.green),
                                            text: AppLocalizations.of(context)!
                                                .linkSubmitted,
                                          ),
                                          gravity: ToastGravity.BOTTOM,
                                          toastDuration:
                                              const Duration(seconds: 3));
                                    }).catchError((error) {
                                      setState(() => loading = false);
                                      String errorMessage =
                                          AppLocalizations.of(context)!
                                              .errorSendingLink;
                                      if (error.runtimeType != String &&
                                          error.message is Map) {
                                        error.message.forEach((index, value) {
                                          switch (value) {
                                            case "passwords.throttled":
                                              errorMessage =
                                                  AppLocalizations.of(context)!
                                                      .waitSendLinkAgain;
                                              break;
                                            case "email":
                                              errorMessage =
                                                  error.message['email'];
                                              break;
                                            default:
                                              errorMessage =
                                                  AppLocalizations.of(context)!
                                                      .emailNotFound;
                                              break;
                                          }
                                        });
                                      }
                                      fToast.showToast(
                                        child: CustomToast(
                                          backgroundColor: Colors.red,
                                          icon: Icon(Icons.close,
                                              color: Colors.white),
                                          text: errorMessage,
                                          textColor: Colors.white,
                                        ),
                                        gravity: ToastGravity.BOTTOM,
                                        toastDuration:
                                            const Duration(seconds: 3),
                                      );
                                    });
                                  }
                                },
                          child: loading
                              ? CircularProgressIndicator(
                                  color: Theme.of(context).highlightColor)
                              : Text(
                                  AppLocalizations.of(context)!.sendLink,
                                  style: poppinsRegular.copyWith(
                                  color: Theme.of(context).highlightColor),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'amplifyconfiguration.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // gives our app awareness about whether we are succesfully connected to the cloud
  bool _amplifyConfigured = false;

  // Instantiate Amplify
  Amplify amplifyInstance = Amplify();

  // controllers for text input
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSignUpComplete = false;
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();

    // amplify is configured on startup
    _configureAmplify();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void _configureAmplify() async {
    if (!mounted) return;

    // add all of the plugins we are currently using
    // in our case... just one - Auth
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    amplifyInstance.addPlugin(authPlugins: [authPlugin]);

    await amplifyInstance.configure(amplifyconfig);
    try {
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> _registerUser(LoginData data) async {
    try {
      Map<String, dynamic> userAttributes = {
        "email": emailController.text,
      };
      SignUpResult res = await Amplify.Auth.signUp(
          username: data.name,
          password: data.password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      setState(() {
        isSignUpComplete = res.isSignUpComplete;
        print("Sign up: " + (isSignUpComplete ? "Complete" : "Not Complete"));
      });
    } on AuthError catch (e) {
      print(e);
      return "Register Error: " + e.toString();
    }
  }

  Future<String> _signIn(LoginData data) async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: data.name,
        password: data.password,
      );
      setState(() {
        isSignedIn = res.isSignedIn;
      });

      if (isSignedIn)
        Alert(context: context, type: AlertType.success, title: "Login Success")
            .show();
    } on AuthError catch (e) {
      print(e);
      Alert(context: context, type: AlertType.error, title: "Login Failed")
          .show();
      return 'Log In Error: ' + e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FlutterLogin(
          logo: 'assets/vennify_media.png',
          onLogin: _signIn,
          onSignup: _registerUser,
          onRecoverPassword: (_) => null,
          title: 'Flutter Amplify'),
    );
  }
}

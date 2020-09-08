import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
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

  bool _amplifyConfigured = false;
  String _userId;
  String _plan;

  // Instantiate Amplify
  Amplify amplifyInstance = Amplify();

  @override
  void initState() {
    super.initState();

    // amplify is configured on startup
    _configureAmplify();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the

    super.dispose();
  }

  void _configureAmplify() async {
    if (!mounted) return;

    // add all of the plugins we are currently using
    // in our case... just one - Auth
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    AmplifyAnalyticsPinpoint analyticsPlugin = AmplifyAnalyticsPinpoint();

    amplifyInstance.addPlugin(
        authPlugins: [authPlugin], analyticsPlugins: [analyticsPlugin]);

    await amplifyInstance.configure(amplifyconfig);
    try {
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }


  void _createEvent() {
    // lets log an app launch event
    AnalyticsEvent event = AnalyticsEvent("test_event");

    event.properties.addBoolProperty("boolKey", true);
    event.properties.addDoubleProperty("doubleKey", 10.0);
    event.properties.addIntProperty("intKey", 10);
    event.properties.addStringProperty("stringKey", "stringValue");
    event.properties.addIntProperty("aNumber", 3);

    Amplify.Analytics.recordEvent(event: event);
    Amplify.Analytics.flushEvents();

    print("event logged");
  }

  void _identifyUser() async {
    AnalyticsUserProfile analyticsUserProfile = new AnalyticsUserProfile();
    analyticsUserProfile.name = _userId + "_name";
    analyticsUserProfile.plan = _plan + "_plan";

    Amplify.Analytics.identifyUser(
        userId: _userId, userProfile: analyticsUserProfile);
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40,),
            RaisedButton(
              onPressed: _createEvent,
              child: Text("Create Event"),
            ),
            Divider(height: 10,),
            TextField(
                decoration: InputDecoration(hintText: 'Enter user name'),
                onChanged: (text) {
                  _userId = text;
                }),
            Divider(height: 10,),
            TextField(
                decoration: InputDecoration(hintText: 'Enter plan name'),
                onChanged: (text) {
                  _plan = text;
                }),
            RaisedButton(onPressed: _identifyUser, child: Text("Add Endpoint Properties")),
          ],
        ),
      ),
    ));

  }
}

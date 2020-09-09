import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'amplifyconfiguration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;
  String _uploadFileResult = '';
  String _getUrlResult = '';
  String _removeResult = '';
  Amplify amplify = new Amplify();

  @override
  void initState() {
    super.initState();

    configureAmplify();
  }

  void configureAmplify() async {
    // First add plugins (Amplify native requirements)
    AmplifyStorageS3 storage = new AmplifyStorageS3();
    AmplifyAuthCognito auth = new AmplifyAuthCognito();
    amplify.addPlugin(authPlugins: [auth], storagePlugins: [storage]);

    // Configure
    await amplify.configure(amplifyconfig);

    setState(() {
      _isAmplifyConfigured = true;
    });
  }

  void _upload() async {
    try {
      print('In upload');
      File local = await FilePicker.getFile(type: FileType.image);
      final key = 'ExampleKey';
      Map<String, String> metadata = <String, String>{};
      metadata['name'] = 'smiley_face';
      metadata['desc'] = 'A photo of a smiley face';
      S3UploadFileOptions options = S3UploadFileOptions(
          accessLevel: StorageAccessLevel.guest, metadata: metadata);
      UploadFileResult result = await Amplify.Storage.uploadFile(
          key: key, local: local, options: options);
      setState(() {
        _uploadFileResult = result.key;
      });
    } catch (e) {
      print('UploadFile Err: ' + e.toString());
    }
  }

  void getUrl() async {
    try {
      String key = "ExampleKey";
      S3GetUrlOptions options = S3GetUrlOptions(
          accessLevel: StorageAccessLevel.guest, expires: 10000);
      GetUrlResult result =
      await Amplify.Storage.getUrl(key: key, options: options);

      setState(() {
        _getUrlResult = result.url;
      });
    } catch (e) {
      print('GetUrl Err: ' + e.toString());
    }
  }

  void _remove() async {
    try {
      print('In remove');
      String key = "ExampleKey";
      RemoveOptions options =
      RemoveOptions(accessLevel: StorageAccessLevel.guest);
      RemoveResult result =
      await Amplify.Storage.remove(key: key, options: options);

      setState(() {
        _removeResult = result.key;
      });
      print('_removeResult:' + _removeResult);
    } catch (e) {
      print('Remove Err: ' + e.toString());
    }
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Amplify Flutter Storage Application'),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            RaisedButton(
              onPressed: _upload,
              child: const Text('Upload File'),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            RaisedButton(
              onPressed: _remove,
              child: const Text('Delete File'),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            RaisedButton(
              onPressed: getUrl,
              child: const Text('GetUrl for uploaded File'),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            Image.network(_getUrlResult),
          ],

          ),
        ),
      ),
    );
  }
}
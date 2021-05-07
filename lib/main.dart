import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'login_page.dart';
import 'service/auth.dart';
import 'navigation_page.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:motivateme_mobile_app/amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<Database> database =
      openDatabase(join(await getDatabasesPath(), 'motivate_me.db'),
          onCreate: (db, version) {
    // create the database if it doesn't exist

    return db.execute(
        "CREATE TABLE Goals(id INTEGER, title TEXT, description TEXT, monday INTEGER, tuesday INTEGER, wednesday INTEGER, thursday INTEGER, friday INTEGER, saturday INTEGER, sunday INTEGER, start_date DATETIME, end_date DATETIME, start_time DATETIME, end_time DATETIME, is_complete INTEGER)");
  }, version: 1);
  runApp(MyApp());
}

// 1
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MotivateMe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primaryColor: Color(0xff5480c1),
            fontFamily: 'Montserrat'),

        // 2
        home: FutureBuilder(
          future: authService.checkUserSession(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                Amplify.Auth.fetchUserAttributes().then((value) {
                  for (var attribute in value) {
                    print(attribute.userAttributeKey + ' ' + attribute.value);
                  }
                });
                return NavigationPage();
              } else {
                return LoginPage();
              }
            } else {
              return Scaffold(body: CircularProgressIndicator());
            }
          },
        ));
  }

  void _configureAmplify() async {
    Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
    await Amplify.configure(amplifyconfig);
  }
}

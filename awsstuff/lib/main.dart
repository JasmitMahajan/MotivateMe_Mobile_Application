import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'auth_service.dart';

void main() {
  runApp(MyApp());
}

// 1
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      // 2
      home: Navigator(
        pages: [
          MaterialPage(child: LoginPage()),
          MaterialPage(child: SignUpPage()),
        ],
        onPopPage: (route, result) => route.didPop(result),
      ),
    );
  }
}

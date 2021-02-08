import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'auth_service.dart';
import 'verification_page.dart';
import 'camera_flow.dart';

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
  void initState() {
    super.initState();
    _authService.showLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      // 2
      home: StreamBuilder<AuthState>(
        stream: _authService.authStateController.stream,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return Navigator(
              pages: [
                // 4
                // Show Login Page
                if(snapshot.data.authFlowStatus == AuthFlowStatus.login)
                  MaterialPage(
                    child: LoginPage(
                      didProvideCredentials: _authService.loginWithCredentials,
                      shouldShowSignUp: _authService.showSignUp)
                  ),

                // 5
                // Show Sign Up Page
                if(snapshot.data.authFlowStatus == AuthFlowStatus.signUp)
                  MaterialPage(
                    child: SignUpPage(
                      didProvideCredentials: _authService.signUpWithCredentials,
                      shouldShowLogin: _authService.showLogin)
                  ),

                if(snapshot.data.authFlowStatus == AuthFlowStatus.verification) 
                  MaterialPage(
                    child: VerificationPage(
                      didProvideVerificationCode: _authService.verifyCode)
                    ),

                if(snapshot.data.authFlowStatus == AuthFlowStatus.session) 
                  MaterialPage(
                    child: CameraFlow(shouldLogOut: _authService.logOut)
                  ),
                
                
              ],
              onPopPage: (route, result) => route.didPop(result),
            );
          } else {
            // 6 
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
        }),
    
    );
  }
}
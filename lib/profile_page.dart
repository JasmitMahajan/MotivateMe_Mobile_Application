import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:motivateme_mobile_app/login_page.dart';
import 'package:motivateme_mobile_app/collage_page.dart';
import 'service/auth.dart';

class ProfilePage extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment
                .centerRight, // 10% of the width, so there are ten blinds.
            colors: [
              const Color(0xffB7F8DB),
              const Color(0xff50A7C2)
            ], // red to yellow
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
            child: Center(
                child: Padding(
              padding: EdgeInsets.only(top: 75.0),
              child: FutureBuilder(
                  future: Amplify.Auth.fetchUserAttributes(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<AuthUserAttribute>> snapshot) {
                    if (snapshot.hasData) {
                      List<AuthUserAttribute> firstName = snapshot.data
                          .where((element) =>
                              element.userAttributeKey == 'custom:first_name')
                          .toList();
                      List<AuthUserAttribute> lastName = snapshot.data
                          .where((element) =>
                              element.userAttributeKey == 'custom:last_name')
                          .toList();
                      String fullName =
                          firstName.first.value + ' ' + lastName.first.value;

                      return Column(children: [
                        Text(fullName == null ? 'Profile Page' : fullName,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),
                        OutlinedButton(
                            child: Text('View Collage', style: TextStyle(fontSize: 18.0,color: Colors.black)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CollagePage()));
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xfff5855b)),
                              elevation:
                                  MaterialStateProperty.all<double>(10.0),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 10.0, bottom: 10.0)),
                        OutlinedButton(
                          child: Text('Sign Out', style: TextStyle(fontSize: 18.0,color: Colors.black)),
                          onPressed: () {
                            authService.logout();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LoginPage()));
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xfff5855b)),
                            elevation: MaterialStateProperty.all<double>(10.0),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                            ),
                          ),
                        )
                      ]);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ))));
  }
}

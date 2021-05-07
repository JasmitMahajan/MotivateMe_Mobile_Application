import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'navigation_page.dart';
import 'service/auth.dart';
import 'model/sign_up_result.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
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
          child: Container(
              child: Stack(children: [
            // Sign Up Form
            SingleChildScrollView(
              padding: EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
              child: Column(children: <Widget>[
                Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: _signUpForm(),
                ),
                SizedBox(height: 40.0),
                // Login Button
                new Container(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: new Text(
                      'Already have an account? Login',
                      style: new TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ])),
        ),
      ),
    ));
  }

  Widget _signUpForm() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      //FirstName TextField
      TextFormField(
        validator: validateFirstName,
        controller: _firstNameController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.person),
          hintText: 'First Name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(width: 3.0, color: Colors.red),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(10.0),
      ),

      //LastName TextField
      TextFormField(
        validator: validateLastName,
        controller: _lastNameController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.person),
          hintText: 'Last Name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(10.0),
      ),

      //Email TextField
      TextFormField(
        validator: validateEmail,
        controller: _emailController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.email),
          hintText: 'Email',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(10.0),
      ),

      // Username TextField
      TextFormField(
        validator: validateUsername,
        controller: _usernameController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.person),
          hintText: 'Username',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.all(10.0),
      ),

      // Password TextField
      TextFormField(
        validator: validatePassword,
        controller: _passwordController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(Icons.lock),
          hintText: 'Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
      ),

      Padding(
        padding: const EdgeInsets.all(16.0),
      ),

      // Sign Up Button
      SizedBox(
        width: 300.0,
        height: 40.0,
        child: OutlinedButton(
          child: new Text(
            'Sign Up',
            style: new TextStyle(fontSize: 17.0, color: Colors.white),
          ),
          onPressed: _validateInputs,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor),
            elevation: MaterialStateProperty.all<double>(10.0),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _signUp();
    } else {
      setState(() {
        _autoValidate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  String validateFirstName(String value) {
    if (value.length == 0)
      return 'First name is required';
    else
      return null;
  }

  String validateLastName(String value) {
    if (value.length == 0)
      return 'Last name is required';
    else
      return null;
  }

  String validateUsername(String value) {
    if (value.length == 0)
      return 'Username is required';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter a valid email';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length < 7)
      return 'Password must have more than 8 characters';
    else
      return null;
  }

  void _signUp() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    print('firstName: $firstName');
    print('lastName: $lastName');
    print('email: $email');
    print('username: $username');
    print('password: $password');

    SignUpResult result = await authService.signUp(
        username, password, email, firstName, lastName);
    if (result == SignUpResult.SUCCESS) {
      await authService.login(username, password);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => NavigationPage()));
    } else {
      _showMyDialog();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Username already exists'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

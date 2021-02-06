import 'package:flutter/material.dart';
import 'package:home_stock/screens/authentication/forgotPassword.dart';
import 'package:home_stock/screens/shared/loading.dart';
import 'package:home_stock/services/auth.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:home_stock/screens/home/home.dart';
import 'package:home_stock/services/database.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  //text field state
  String email = "";
  String password = "";
  String error = "";

  LocalAuthentication _auth1 = LocalAuthentication();
  bool _checkBio= false;
  bool _isBioFinger= false;

  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _listBioAndFingerType();
  }

  @override
  Widget build(BuildContext context) {



    void _showResetPasswordPanel(){
      showModalBottomSheet(context: context, isScrollControlled: true ,builder: (context){
        return ForgotPassword();
      });
    }

    return  loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[700],
        elevation: 0.0,
        title: Text('Mr House'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              Image(image: AssetImage('assets/homestockLogo.png')),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: myController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                      validator: (val) => val.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() {
                          email = val;
                        });
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                      validator: (val) => val.length < 6 ? 'Enter a password at least 6 characters long' : null,
                      onChanged: (val) {
                        setState(() {
                          password = val;
                        });
                      },
                    ),
                    SizedBox(height: 20.0),
                    InkWell(
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: Colors.lightGreen[700],
                            fontSize: 14.0,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onTap: () {
                        _showResetPasswordPanel();
                      },
                    ),
                    SizedBox(height: 20.0),
                    // ignore: deprecated_member_use
                    RaisedButton(
                      onPressed: () async {
                        if(_formKey.currentState.validate()) {
                          setState(() {
                            loading = true;
                          });
                          dynamic result = await _auth.signInWithEmailAndPasswors(email, password);
                          if(result == null) {
                            setState(() {
                              loading = false;
                              error = 'Error Signing In';
                            });
                          }
                        }
                      },
                      color: Colors.lightGreen[700],
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    SizedBox(height: 20.0),
                    InkWell(
                      child: Text(
                        'Don\'t have an account? Register',
                        style: TextStyle(
                            color: Colors.lightGreen[700],
                            fontSize: 16.0,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onTap: () {
                        widget.toggleView();
                      },
                    ),
                    SizedBox(height: 20.0),
                    InkWell(
                      child: Text(
                        'Use fingerprint instead',
                        style: TextStyle(
                            color: Colors.lightGreen[700],
                            fontSize: 16.0,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onTap: _startAuth,
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

  void _checkBiometrics() async {
    try {
      final bio= await _auth1.canCheckBiometrics;
      setState(() {
        _checkBio= bio;
      });
      print( 'Biometrics= $_checkBio');
    } catch (e) {}

  } //end method

  void _listBioAndFingerType () async {
    List<BiometricType> _listType;
    try {
      _listType = await _auth1.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e.message);
    }
    print ('List Biometrics = $_listType');

    if (_listType.contains(BiometricType.fingerprint)) {
      setState(() {
        _isBioFinger = true;
      });
    } //end if
    print('Fingerprint is $_isBioFinger');
  } //end void



  void _startAuth() async {
    bool _isAuthenticated= false;
    AndroidAuthMessages _msg= AndroidAuthMessages(
      signInTitle: 'Sign in to enter',
      cancelButton: 'Cancel',
    );
    try {
      _isAuthenticated= await  _auth1.authenticateWithBiometrics(
        localizedReason: 'Scan your fingerprint',
        useErrorDialogs: true,
        stickyAuth: true,// native process
        androidAuthStrings: _msg,
      );
    } on PlatformException catch (e) {
      print(e.message);
    }

    if (_isAuthenticated) {
      setState(() {
        loading = true;
      });
      dynamic result = await _auth.signInWithEmailAndPasswors('nuradilasyarmila@gmail.com', 'honeydew99');
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Home()));

    }
  }
}
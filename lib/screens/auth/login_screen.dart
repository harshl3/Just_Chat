////****Dummy non used File **** insted this i used email resistration ////
//// as gmail login is not working and it gives an errors hence email login is used ////


import 'dart:developer' as dev;



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }



  // Future<UserCredential> _signInWithGoogle() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
  //       .authenticate();
  //
  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth = googleUser!.authentication;
  //
  //   // Create a new credential
  //   final credential = GoogleAuthProvider.credential(
  //     idToken: googleAuth.idToken,
  //   );
  //
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  //
  // Future<bool> handleGoogleBtnClick() async {
  //   try {
  //     // Create an instance
  //     // final GoogleSignIn googleSignIn = GoogleSignIn();
  //
  //     final GoogleSignIn googleSignIn = GoogleSignIn(
  //       clientId: "98910437031-fncqh1o6dc7e8b1efvncjs90plcdgfit.apps.googleusercontent.com",
  //       scopes: ['email'],
  //     );
  //
  //
  //     // Start the sign-in process
  //     final GoogleSignInAccount? user = await googleSignIn.signIn();
  //
  //     if (user == null) return false; // User cancelled login
  //
  //     // Get authentication details
  //     final GoogleSignInAuthentication userAuth = await user.authentication;
  //
  //     // Create credential for Firebase
  //     final credential = GoogleAuthProvider.credential(
  //       idToken: userAuth.idToken,
  //       accessToken: userAuth.accessToken, // may be null on web
  //     );
  //
  //     // Sign in with Firebase
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     return FirebaseAuth.instance.currentUser != null;
  //   } catch (e) {
  //     print("Error during Google Sign-In: $e");
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;

    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome to We Chat"),
      ),

      body: Stack(
        children: [
          //app logo
          AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: Duration(seconds: 1),
            child: Image.asset('images/icon.png'),
          ),

          //google login button
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                // backgroundColor: Color.fromARGB(255, 223, 255, 187),
                backgroundColor: Colors.lightGreenAccent.shade100,
                elevation: 1,
              ),
              onPressed: () {

              },

              //google icon
              icon: Image.asset('images/google.png', height: mq.height * .03),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 17),
                  children: [
                    TextSpan(text: '  Login with '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

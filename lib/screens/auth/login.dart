import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../api/apis.dart';
import '../../main.dart';
import '../home_screen.dart';
import 'register.dart';
import 'profile_setup_screen.dart';
import '../../utils/validators.dart';
import 'dart:developer' as dev;

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  var email = TextEditingController();

  var pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Login"),
      //   centerTitle: true,
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
            transform: GradientRotation(120 * 3.1415926535 / 180),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: mq.height * .06),
                  AnimatedAlign(
                    alignment: _isAnimate
                        ? Alignment.center
                        : Alignment.topCenter,
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    child: Image.asset('images/icon.png', width: mq.width * .5),
                  ),
                  SizedBox(height: 55),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: "Enter Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: pass,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: "Enter Password",
                      prefixIcon: Icon(Icons.lock_person_rounded),
                    ),
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
                      String mail = email.text.trim();
                      String pas = pass.text.trim();

                      if (mail.isEmpty || pas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Enter Email and Password")),
                        );
                      } else if (!Validators.isValidEmail(mail)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Enter a valid email address"),
                          ),
                        );
                      } else if (pas.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Password must be at least 6 characters",
                            ),
                          ),
                        );
                      } else {
                        try {
                          final credential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: mail,
                                password: pas,
                              );

                          if (credential.user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Login Successfully")),
                            );

                            // Check if user exists in Firestore
                            if ((await APIs.userExists())) {
                              // User exists, navigate to home
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            } else {
                              // User doesn't exist, navigate to profile setup
                              // Initialize APIs.me first
                              await APIs.getSelfInfo();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileSetupScreen(),
                                ),
                              );
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          String message = 'Authentication(login) failed';
                          if (e.code == 'user-not-found') {
                            message = 'No user found for that email.';
                          } else if (e.code == 'wrong-password') {
                            message = 'Wrong password provided.';
                          } else if (e.code == 'invalid-email') {
                            message = 'Invalid email address.';
                          } else if (e.code == 'network-request-failed') {
                            message =
                                'Network error :( Check your internet connection.';
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.greenAccent.withOpacity(
                                .6,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'New User? click here !',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

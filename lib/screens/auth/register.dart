import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';
import '../../api/apis.dart';
import 'login.dart';
import 'profile_setup_screen.dart';
import '../../utils/validators.dart';

class RegisterPage extends StatelessWidget {
  var email = TextEditingController();
  var pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Register"),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: mq.height * .06),
                  Container(
                    child: Image.asset('images/icon.png', width: mq.width * .5),
                  ),
                  SizedBox(height: 35),
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
                      prefixIcon: Icon(Icons.lock),
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
                              .createUserWithEmailAndPassword(
                                email: mail,
                                password: pas,
                              );
                          if (credential.user != null) {
                            // Initialize APIs.me before navigating
                            await APIs.getSelfInfo();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Registered Successfully"),
                              ),
                            );
                            // Navigate to profile setup screen instead of login
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileSetupScreen(),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String message = 'Registration failed';
                          if (e.code == 'email-already-in-use') {
                            message = 'Email already in use.';
                          } else if (e.code == 'invalid-email') {
                            message = 'Invalid email address.';
                          } else if (e.code == 'weak-password') {
                            message = 'Password is too weak.';
                          } else if (e.code == 'network-request-failed') {
                            message =
                                'Network error :( Check your internet connection.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.greenAccent.withAlpha((255 * 0.6).round()),
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
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 25),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Already have an account? Click here !',
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

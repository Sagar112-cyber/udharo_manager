import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:udharo_manager/Screens/homescreen.dart';
import 'package:udharo_manager/Screens/loginscreen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  // ✔ Correct place for FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();   // Call function inside initState
  }

  // ✔ Clean function to check login status
  void checkLoginStatus() async {

    await Future.delayed(const Duration(seconds: 3)); // splash delay

    User? user = _auth.currentUser; // ✔ Get current user

    if (!mounted) return; // ✔ avoid async errors

    // ✔ Correct navigation:
    if (user != null) {
      // User is already logged in → Go to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } else {
      // User NOT logged in → Go to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/first.png'),
          height: 200,
        ),
      ),
    );
  }
}

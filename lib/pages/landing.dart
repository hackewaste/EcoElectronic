import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart'; // Import your LoginPage from login.dart

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 10 seconds, then an additional 2 seconds before navigating to the LoginPage.
    Future.delayed(Duration(seconds: 3), () {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image at the top
            Image.asset(
              'assets/logo.png', // Ensure this asset exists and is declared in pubspec.yaml
              width: 250,
            ),
            const SizedBox(height: 20),
            // Styled text "eco-electronic"
            Text(
              'eco-electronic',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
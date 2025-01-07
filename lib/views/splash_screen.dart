import 'package:flutter/material.dart';
import 'dart:async';
import 'landing_screen.dart'; 
class SplashScreen extends StatefulWidget {
  
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Navigasi ke landing screen setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          
          builder: (context) => LandingScreen(), 
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5DAA80), 
      body: Center(
        child: Image.asset(
          'assets/images/logosplash.png',
          width: 200, 
          height: 200,
        ),
      ),
    );
  }
}
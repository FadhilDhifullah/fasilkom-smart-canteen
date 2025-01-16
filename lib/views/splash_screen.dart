import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seller_main_screen.dart';
import 'customer_main_screen.dart';
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
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginRole = prefs.getString('lastLoginRole');
    final lastUid = prefs.getString('lastUid');
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && lastUid == user.uid) {
      if (lastLoginRole == 'seller') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SellerMainScreen(uid: user.uid),
          ),
        );
        return;
      } else if (lastLoginRole == 'customer') {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CustomerMainScreen(
              uid: user.uid,
              userData: userDoc.data() ?? {},
              isGuest: false,
            ),
          ),
        );
        return;
      }
    }

    // Jika tidak ada login sebelumnya, arahkan ke LandingScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LandingScreen(),
      ),
    );
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

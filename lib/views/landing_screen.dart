import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'seller_main_screen.dart';
import 'customer_main_screen.dart';
import 'registration_options_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LandingScreen extends StatelessWidget {
  Future<void> _navigateBasedOnHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginRole = prefs.getString('lastLoginRole');

    if (lastLoginRole == 'seller') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerMainScreen(uid: FirebaseAuth.instance.currentUser!.uid),
        ),
      );
    } else if (lastLoginRole == 'customer') {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerMainScreen(
            uid: FirebaseAuth.instance.currentUser!.uid,
            userData: userDoc.data() ?? {},
            isGuest: false,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerMainScreen(
            uid: 'guest_user',
            userData: {
              'email': 'guest@example.com',
              'fullName': 'Guest User',
            },
            isGuest: true,
          ),
        ),
      );
    }
  }

  Future<void> _handleSkip(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      prefs.setString('lastLoginRole', 'customer');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerMainScreen(
            uid: user.uid,
            userData: userDoc.data() ?? {},
            isGuest: false,
          ),
        ),
      );
    } else {
      prefs.setString('lastLoginRole', 'guest');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerMainScreen(
            uid: 'guest_user',
            userData: {
              'email': 'guest@example.com',
              'fullName': 'Guest User',
            },
            isGuest: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFF5DAA80),
      body: Stack(
        children: [
          Positioned(
            top: size.height * 0.1,
            left: -30,
            child: Image.asset(
              'assets/images/mielandingscreen.png',
              width: size.width * 0.5,
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            right: 0,
            child: Image.asset(
              'assets/images/rendanglandingsreen.png',
              width: size.width * 0.5,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
                child: Text(
                  "Hemat waktu,\nBebas antri,\nSolusi cepat untuk\nperut lapar di\nKampus.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02,
                        ),
                      ),
                      onPressed: () => _handleSkip(context),
                      child: Text(
                        'Lewati',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.045,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFA31D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationOptionsScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.045,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ],
      ),
    );
  }
}
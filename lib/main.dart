import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';
import 'views/seller_main_screen.dart';
import 'views/customer_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginRole = prefs.getString('lastLoginRole');
    final lastUid = prefs.getString('lastUid');
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && lastUid == user.uid) {
      if (lastLoginRole == 'seller') {
        return SellerMainScreen(uid: user.uid);
      } else if (lastLoginRole == 'customer') {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return CustomerMainScreen(
          uid: user.uid,
          userData: userDoc.data() ?? {},
          isGuest: false,
        );
      }
    }
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan.'));
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Canteen',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: snapshot.data ?? const SplashScreen(),
        );
      },
    );
  }
}

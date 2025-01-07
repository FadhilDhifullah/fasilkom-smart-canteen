import 'package:flutter/material.dart';
import 'package:apilikasi_smart_canteen/views/auth/canteen_seller_registration_screen.dart';
import 'package:apilikasi_smart_canteen/views/auth/customer_registration_screen.dart'; // Import CustomerRegistrationScreen
import 'auth/canteen_seller_login_screen.dart';
import 'landing_screen.dart'; // Import LandingScreen

class RegistrationOptionsScreen extends StatefulWidget {
  @override
  _RegistrationOptionsScreenState createState() =>
      _RegistrationOptionsScreenState();
}

class _RegistrationOptionsScreenState
    extends State<RegistrationOptionsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  int? _selectedOption; // Menyimpan opsi yang dipilih

  @override
  void initState() {
    super.initState();
    // Animasi untuk form yang muncul dari bawah
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Muncul dari bawah
      end: Offset.zero, // Berhenti di posisi normal
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward(); // Memulai animasi
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5DAA80),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logosplash.png',
                      width: 250,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bagian bawah dengan form yang muncul dari bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol kembali
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LandingScreen(),
                              ),
                            );
                          },
                        ),
                        // Judul
                        const Text(
                          "Daftar Akun",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 48), // Placeholder untuk menjaga alignment
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Opsi daftar sebagai pembeli
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOption = 1;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerRegistrationScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: _selectedOption == 1 ? Colors.black : Colors.grey,
                            ),
                          ),
                          const Text(
                            "Daftar sebagai pembeli",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black54),

                    // Opsi daftar sebagai penjual
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOption = 2;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CanteenSellerRegistrationScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.store,
                              size: 30,
                              color: _selectedOption == 2 ? Colors.black : Colors.grey,
                            ),
                          ),
                          const Text(
                            "Daftar sebagai penjual",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black54),
                    const SizedBox(height: 20),

                    // Link masuk akun
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CanteenSellerLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sudah punya akun? Masuk",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5DAA80),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

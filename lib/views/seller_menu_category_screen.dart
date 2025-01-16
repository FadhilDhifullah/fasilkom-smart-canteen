import 'package:flutter/material.dart';
import 'seller_menu_detail_screen.dart';

class SellerMenuCategoryScreen extends StatelessWidget {
  const SellerMenuCategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text(
          'Kategori Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCategoryItem(context, 'Aneka Nasi', 'assets/images/aneka_nasi.png'),
            _buildCategoryItem(context, 'Mie dan Bakso', 'assets/images/mie_bakso.png'),
            _buildCategoryItem(context, 'Camilan', 'assets/images/camilan.png'),
            _buildCategoryItem(context, 'Minuman', 'assets/images/minuman.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String categoryName, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerMenuDetailScreen(category: categoryName),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0), // Membuat gambar berbentuk lingkaran
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

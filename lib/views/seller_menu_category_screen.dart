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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCategoryItem(context, 'Aneka Nasi'),
            _buildCategoryItem(context, 'Mie dan Bakso'),
            _buildCategoryItem(context, 'Camilan'),
            _buildCategoryItem(context, 'Minuman'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String categoryName) {
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
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
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

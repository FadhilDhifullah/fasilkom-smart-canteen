import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/seller_outlet_viewmodel.dart';
import '../models/seller_outlet_model.dart';
import 'landing_screen.dart';

class SellerOutletScreen extends StatefulWidget {
  final String uid;

  const SellerOutletScreen({required this.uid, Key? key}) : super(key: key);

  @override
  _SellerOutletScreenState createState() => _SellerOutletScreenState();
}

class _SellerOutletScreenState extends State<SellerOutletScreen> {
  final SellerOutletViewModel _viewModel = SellerOutletViewModel();
  SellerOutletModel? outletData;
  bool isLoading = true;

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isShopOpen = false;

  @override
  void initState() {
    super.initState();
    _loadOutletData();
  }

  Future<void> _loadOutletData() async {
    try {
      final sellerData = await _viewModel.getSellerData(widget.uid);
      final outletDataMap = await _viewModel.fetchOrCreateOutletData(widget.uid);

      setState(() {
        outletData = SellerOutletModel.fromMap(outletDataMap);
        _shopNameController.text = outletData?.shopName ?? '';
        _emailController.text = outletData?.email ?? '';
        _phoneController.text = outletData?.phone ?? '';
        _descriptionController.text = outletData?.description ?? '';
        isShopOpen = outletData?.isShopOpen ?? false;

        // Jika imageUrl di outlet kosong, gunakan imageUrl dari seller
        if (outletData?.imageUrl == null || (outletData?.imageUrl?.isEmpty ?? true)) {
  outletData = outletData?.copyWith(imageUrl: sellerData['imageUrl'] ?? '');
}
isLoading = false;

      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      await _viewModel.updateOutletData(widget.uid, {
        'shopName': _shopNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'description': _descriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
      );
    }
  }

  Future<void> _updateShopStatus(bool isOpen) async {
    try {
      await _viewModel.updateOutletData(widget.uid, {'isShopOpen': isOpen});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status toko diperbarui menjadi ${isOpen ? "Buka" : "Tutup"}.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status toko: $e')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final File imageFile = File(pickedFile.path);
        final imageUrl = await _viewModel.uploadProfilePicture(widget.uid, imageFile);
        setState(() {
          outletData = outletData?.copyWith(imageUrl: imageUrl);
        });
        await _viewModel.updateSellerAndOutletImage(widget.uid, imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto profil: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LandingScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (outletData == null) {
      return const Scaffold(
        body: Center(child: Text('Data outlet tidak ditemukan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text(
          'Outlet Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  outletData?.imageUrl ?? 'https://via.placeholder.com/150',
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField('Nama Toko', _shopNameController),
            _buildEditableField('Email', _emailController),
            _buildEditableField('Nomor Telepon', _phoneController),
            _buildEditableField('Deskripsi', _descriptionController),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Buka Toko',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isShopOpen,
                  onChanged: (value) {
                    setState(() {
                      isShopOpen = value;
                    });
                    _updateShopStatus(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA31D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

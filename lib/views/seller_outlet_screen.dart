
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
  bool isEditingPersonalInfo = false;

  // Controllers for edit mode
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
      final data = await _viewModel.fetchOrCreateOutletData(widget.uid);
      setState(() {
        outletData = SellerOutletModel.fromMap(data);
        _shopNameController.text = outletData?.shopName ?? '';
        _emailController.text = outletData?.email ?? '';
        _phoneController.text = outletData?.phone ?? '';
        _descriptionController.text = outletData?.description ?? '';
        isShopOpen = outletData?.isShopOpen ?? false;
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

  Future<void> _saveShopStatus() async {
    try {
      await _viewModel.updateOutletData(widget.uid, {
        'isShopOpen': isShopOpen,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status toko berhasil diperbarui.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status toko: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>LandingScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (outletData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Text('Data outlet tidak ditemukan.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text(
          'Outlet Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informasi Pribadi
            _buildEditableContainer(
              title: 'Informasi Pribadi',
              isEditing: isEditingPersonalInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableField('Nama Toko', _shopNameController, isEditingPersonalInfo),
                  _buildEditableField('Email', _emailController, isEditingPersonalInfo),
                  _buildEditableField('Nomor Telepon', _phoneController, isEditingPersonalInfo),
                  _buildEditableField('Deskripsi', _descriptionController, isEditingPersonalInfo),
                ],
              ),
              onSave: () async {
                setState(() => isEditingPersonalInfo = false);
                // Simpan data
              },
              onCancel: () => setState(() => isEditingPersonalInfo = false),
              onEdit: () => setState(() => isEditingPersonalInfo = true),
            ),
            const SizedBox(height: 16),

            // Buka Toko
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Buka Toko',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isShopOpen,
                  onChanged: (value) {
                    setState(() {
                      isShopOpen = value;
                    });
                    _saveShopStatus();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableContainer({
    required String title,
    required Widget child,
    required bool isEditing,
    required VoidCallback onSave,
    required VoidCallback onCancel,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF5DAA80),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: onEdit,
              ),
            ],
          ),
          child,
          if (isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: onSave,
                  child: const Text('Simpan'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

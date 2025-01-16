import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/customer_profile_viewmodel.dart';
import '../models/customer_model.dart';
import 'landing_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String uid;

  const CustomerProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final CustomerProfileViewModel _viewModel = CustomerProfileViewModel();
  Customer? customerData;
  bool isLoading = true;

  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _subdistrictController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      final data = await _viewModel.fetchCustomerData(widget.uid);
      setState(() {
        customerData = data;
        _nimController.text = data?.nomorIndukMahasiswa ?? '';
        _provinceController.text = data?.address?['province'] ?? '';
        _cityController.text = data?.address?['city'] ?? '';
        _subdistrictController.text = data?.address?['subdistrict'] ?? '';
        _fullNameController.text = data?.fullName ?? '';
        _phoneNumberController.text = data?.phoneNumber ?? '';
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                prefs.remove('lastLoginRole');
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
            },
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
    );
  }

  Future<void> _updateProfile() async {
    try {
      await _viewModel.updateCustomerData(widget.uid, {
        'nomorIndukMahasiswa': _nimController.text,
        'address': {
          'province': _provinceController.text,
          'city': _cityController.text,
          'subdistrict': _subdistrictController.text,
        },
        'fullName': _fullNameController.text,
        'phoneNumber': _phoneNumberController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diperbarui')),
      );
      await _loadCustomerData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data: $e')),
      );
    }
  }

  Future<void> _resetPassword() async {
    try {
      final email = customerData?.email;
      if (email == null || email.isEmpty) {
        throw 'Email tidak tersedia untuk akun ini.';
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email reset password telah dikirim.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim email reset password: $e')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final imageUrl = await _viewModel.uploadProfilePicture(
          widget.uid,
          File(pickedFile.path),
        );
        await _viewModel.updateCustomerData(widget.uid, {'profilePicture': imageUrl});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar profil berhasil diperbarui')),
        );
        await _loadCustomerData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (customerData == null) {
      return const Scaffold(
        body: Center(child: Text('Data pelanggan tidak ditemukan.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text(
          'Akun',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  customerData?.profilePicture ?? 'https://via.placeholder.com/150',
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField('Nama Lengkap', _fullNameController),
            _buildEditableField('Nomor Telepon', _phoneNumberController),
            _buildEditableField('NIM', _nimController),
            _buildEditableField('Provinsi', _provinceController),
            _buildEditableField('Kota', _cityController),
            _buildEditableField('Kecamatan', _subdistrictController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateProfile,
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
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Reset Password',
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

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../viewmodels/customer_profile_viewmodel.dart';
import '../models/customer_model.dart';

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

  Future<void> _updateProfile() async {
    try {
      await _viewModel.updateCustomerData(widget.uid, {
        'nomorIndukMahasiswa': _nimController.text,
        'address': {
          'province': _provinceController.text,
          'city': _cityController.text,
          'subdistrict': _subdistrictController.text,
        },
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
        title: const Text('Akun', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto Profil
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

            // NIM dan Alamat
            _buildEditableField('NIM', _nimController),
            _buildEditableField('Provinsi', _provinceController),
            _buildEditableField('Kota', _cityController),
            _buildEditableField('Kecamatan', _subdistrictController),
            const SizedBox(height: 24),

            // Tombol Simpan
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA31D),
                fixedSize: const Size(200, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Simpan Perubahan'),
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

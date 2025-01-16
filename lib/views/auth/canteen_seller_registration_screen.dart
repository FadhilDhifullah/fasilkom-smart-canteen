import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/seller_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'canteen_seller_login_screen.dart'; // Pastikan import login screen

class CanteenSellerRegistrationScreen extends StatefulWidget {
  const CanteenSellerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<CanteenSellerRegistrationScreen> createState() =>
      _CanteenSellerRegistrationScreenState();
}

class _CanteenSellerRegistrationScreenState
    extends State<CanteenSellerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _canteenNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final AuthViewModel _authViewModel = AuthViewModel();
  bool _isLoading = false;
  File? _imageFile;

  @override
  void dispose() {
    _canteenNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef =
          FirebaseStorage.instance.ref().child('canteen_images/$fileName');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _registerSeller() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final imageUrl = await _uploadImage(_imageFile!);
        if (imageUrl == null) {
          throw "Gagal mengunggah gambar.";
        }

        SellerModel seller = SellerModel(
          canteenName: _canteenNameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: imageUrl,
        );

        await _authViewModel.registerSeller(seller, _passwordController.text.trim());
        _showSuccessDialog();
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (_imageFile == null) {
        _showErrorDialog("Silakan unggah gambar terlebih dahulu.");
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Registrasi Berhasil"),
          content: const Text(
              "Akun Anda berhasil didaftarkan. Silakan login menggunakan akun Anda."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Registrasi Gagal"),
          content: Text(
            "Terjadi kesalahan: $message",
            style: const TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5DAA80),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                margin: const EdgeInsets.only(top: 100),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);  // Menavigasi kembali ke layar sebelumnya
                            },
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                "Daftar sebagai penjual",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        label: "Nama Kantin",
                        controller: _canteenNameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama kantin tidak boleh kosong'
                            : null,
                      ),
                      _buildInputField(
                        label: "Email",
                        controller: _emailController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Email tidak boleh kosong'
                            : null,
                      ),
                      _buildInputField(
                        label: "Alamat",
                        controller: _addressController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Alamat tidak boleh kosong'
                            : null,
                      ),
                      _buildInputField(
                        label: "Deskripsi",
                        controller: _descriptionController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Deskripsi tidak boleh kosong'
                            : null,
                      ),
                      _buildPasswordInputField(),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: _imageFile == null
                                ? const Text("Pilih Gambar",
                                    style: TextStyle(color: Colors.grey))
                                : const Text("Gambar Dipilih",
                                    style: TextStyle(color: Colors.green)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA31D),
                            fixedSize: const Size(176, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoading ? null : _registerSeller,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Buat Akun Baru",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPasswordInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kata Sandi",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Kata sandi tidak boleh kosong' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/menu_model.dart';
import '../viewmodels/menu_viewmodel.dart';

class AddMenuScreen extends StatefulWidget {
  final String category;

  const AddMenuScreen({Key? key, required this.category}) : super(key: key);

  @override
  _AddMenuScreenState createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  String? _canteenName; // Nama kantin yang sedang login
  String? _canteenId; // ID kantin yang sedang login

  final MenuViewModel _viewModel = MenuViewModel();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCanteenInfo();
  }

  Future<void> _fetchCanteenInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final canteenDoc = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(user.uid)
            .get();
        if (canteenDoc.exists) {
          setState(() {
            _canteenName = canteenDoc.data()?['canteenName'] ?? 'Kantin';
            _canteenId = canteenDoc.data()?['uid'] ?? ''; // Dapatkan canteenId
          });
        } else {
          setState(() {
            _canteenName = 'Kantin';
            _canteenId = '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil informasi kantin: $e')),
      );
      setState(() {
        _canteenName = 'Kantin';
        _canteenId = '';
      });
    }
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

  Future<void> _addMenu() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan upload gambar')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw 'Pengguna tidak ditemukan';

        // Upload gambar ke Firebase Storage
        final imageUrl = await _viewModel.uploadImage(_imageFile!);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengunggah gambar')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Buat objek menu
        final menu = MenuModel(
          id: '', // Akan dibuat otomatis oleh Firestore
          name: _nameController.text,
          category: widget.category,
          stock: int.parse(_stockController.text),
          price: double.parse(_priceController.text.replaceAll('.', '')),
          imageUrl: imageUrl,
          uid: user.uid,
          canteenName: _canteenName ?? 'Kantin',
          canteenId: _canteenId ?? '', // Tambahkan canteenId
        );

        // Simpan menu ke Firestore
        await _viewModel.addMenu(menu);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu berhasil ditambahkan')),
        );

        // Kembali ke halaman sebelumnya
        Navigator.pop(context, true); // Kirim nilai true untuk menyegarkan data di halaman sebelumnya
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan menu: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll('.', ''));
    if (number == null) return '';
    return number.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tambahkan Menu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: widget.category,
                    enabled: false,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nama menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama menu tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Stok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Harga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    onChanged: (value) {
                      _priceController.value = TextEditingValue(
                        text: _formatCurrency(value),
                        selection: TextSelection.collapsed(offset: _formatCurrency(value).length),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Upload gambar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: _imageFile == null
                            ? const Text('Pilih Gambar', style: TextStyle(color: Colors.grey))
                            : const Text('Gambar Dipilih', style: TextStyle(color: Colors.green)),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _addMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA31D),
                        fixedSize: const Size(117, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Tambahkan', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

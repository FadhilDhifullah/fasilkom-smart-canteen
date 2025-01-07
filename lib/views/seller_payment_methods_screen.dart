import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/payment_method_viewmodel.dart';
import '../models/payment_method_model.dart';

class SellerPaymentMethodsScreen extends StatefulWidget {
  @override
  _SellerPaymentMethodsScreenState createState() =>
      _SellerPaymentMethodsScreenState();
}

class _SellerPaymentMethodsScreenState
    extends State<SellerPaymentMethodsScreen> {
  bool isCODSelected = false;
  bool isQRISSelected = false;
  File? _qrisImageFile;
  bool isLoading = false;
  String? userId; // Variabel untuk menyimpan ID pengguna yang sedang login

  final PaymentMethodViewModel _viewModel = PaymentMethodViewModel();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _fetchPaymentMethods(user.uid);
    }
  }

  Future<void> _fetchPaymentMethods(String uid) async {
    try {
      final methods = await _viewModel.fetchPaymentMethods(uid);
      if (methods != null) {
        setState(() {
          isCODSelected = methods.isCOD;
          isQRISSelected = methods.isQRIS;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat metode pembayaran: $e')),
      );
    }
  }

  Future<void> _pickQRISImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _qrisImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePaymentMethods() async {
    if (isQRISSelected && _qrisImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan unggah QRIS terlebih dahulu')),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan, pengguna tidak ditemukan')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? qrisUrl;
      if (isQRISSelected && _qrisImageFile != null) {
        qrisUrl = await _viewModel.uploadQRISImage(userId!, _qrisImageFile!);
      }

      final methods = PaymentMethodModel(
        sellerId: userId!,
        isCOD: isCODSelected,
        isQRIS: isQRISSelected,
        qrisUrl: qrisUrl,
      );

      // Pastikan `userId` digunakan sebagai `uid` dan `sellerId`
      await _viewModel.savePaymentMethods(userId!, userId!, methods);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metode pembayaran berhasil disimpan')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan metode pembayaran: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text(
          'Pilih Metode',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih metode pembayaran Anda:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text(
                    'COD',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                      'Pembayaran dapat dilakukan dengan tunai/cash'),
                  value: isCODSelected,
                  onChanged: (value) {
                    setState(() {
                      isCODSelected = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text(
                    'QRIS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                      'Pembayaran dapat dilakukan dengan scan kode QR'),
                  value: isQRISSelected,
                  onChanged: (value) {
                    setState(() {
                      isQRISSelected = value ?? false;
                    });
                  },
                ),
                if (isQRISSelected)
                  GestureDetector(
                    onTap: _pickQRISImage,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Text('Unggah QRIS',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black)),
                          const Spacer(),
                          if (_qrisImageFile == null)
                            const Icon(Icons.upload, color: Colors.grey)
                          else
                            const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _savePaymentMethods,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA31D),
                      fixedSize: const Size(200, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Konfirmasi',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
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

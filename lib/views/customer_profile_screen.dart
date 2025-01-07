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

    final fullName = customerData?.fullName ?? 'Nama tidak tersedia';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.length > 1
        ? nameParts.sublist(0, nameParts.length - 1).join(' ')
        : nameParts.isNotEmpty
            ? nameParts[0]
            : '';
    final lastName = nameParts.length > 1 ? nameParts.last : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text(
          'Akun',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto Profil
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                customerData?.toMap()['profilePicture'] ?? 'https://via.placeholder.com/150',
              ),
            ),
            const SizedBox(height: 16),

            // Nama
            Text(
              firstName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (lastName.isNotEmpty)
              Text(
                lastName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),

            // Informasi Pribadi
            _buildInfoContainer(
              'Informasi Pribadi',
              {
                'Nama Awal': firstName,
                'Nama Akhir': lastName,
                'Email': customerData?.email ?? '-',
                'Nomor Telepon': customerData?.phoneNumber ?? '-',
              },
            ),
            const SizedBox(height: 16),

            // Alamat
            _buildInfoContainer(
              'Alamat',
              {
                'Provinsi': customerData?.address?['province'] ?? '-',
                'Kota': customerData?.address?['city'] ?? '-',
                'Kecamatan': customerData?.address?['subdistrict'] ?? '-',
              },
            ),
            const SizedBox(height: 24),

            // Tombol Ubah Kata Sandi
            ElevatedButton(
              onPressed: () {
                // Aksi untuk ubah kata sandi
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA31D),
                fixedSize: const Size(200, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ubah Kata Sandi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String title, Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(entry.key, style: const TextStyle(fontSize: 14)),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(entry.value, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

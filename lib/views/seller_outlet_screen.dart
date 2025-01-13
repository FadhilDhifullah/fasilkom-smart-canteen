import 'package:flutter/material.dart';
import '../../viewmodels/seller_outlet_viewmodel.dart';
import '../../models/seller_outlet_model.dart';


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
  bool isEditingOperationalInfo = false;

  // Controllers for edit mode
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
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
        _ownerNameController.text = outletData?.ownerName ?? '';
        _shopNameController.text = outletData?.shopName ?? '';
        _emailController.text = outletData?.email ?? '';
        _phoneController.text = outletData?.phone ?? '';
        _descriptionController.text = outletData?.description ?? '';
        _openTimeController.text = outletData?.openTime ?? '00:00';
        _closeTimeController.text = outletData?.closeTime ?? '00:00';
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

  Future<void> _savePersonalInfo() async {
    if (outletData != null) {
      await _viewModel.updateOutletData(widget.uid, {
        'ownerName': _ownerNameController.text,
        'shopName': _shopNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'description': _descriptionController.text,
      });
      setState(() {
        isEditingPersonalInfo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pribadi berhasil diperbarui.')),
      );
    }
  }

  Future<void> _saveOperationalInfo() async {
    await _viewModel.updateOutletData(widget.uid, {
      'openTime': _openTimeController.text,
      'closeTime': _closeTimeController.text,
    });
    setState(() {
      isEditingOperationalInfo = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data operasional berhasil diperbarui.')),
    );
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
        automaticallyImplyLeading: false, // Hilangkan tombol kembali
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
              onSave: _savePersonalInfo,
              onCancel: () {
                setState(() {
                  isEditingPersonalInfo = false;
                });
              },
              onEdit: () {
                setState(() {
                  isEditingPersonalInfo = true;
                });
              },
            ),
            const SizedBox(height: 16),

            // Jam Operasional
            _buildEditableContainer(
              title: 'Jam Operasional',
              isEditing: isEditingOperationalInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimePickerField('Jam Buka', _openTimeController, isEditingOperationalInfo, context),
                  _buildTimePickerField('Jam Tutup', _closeTimeController, isEditingOperationalInfo, context),
                ],
              ),
              onSave: _saveOperationalInfo,
              onCancel: () {
                setState(() {
                  isEditingOperationalInfo = false;
                });
              },
              onEdit: () {
                setState(() {
                  isEditingOperationalInfo = true;
                });
              },
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
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('Batal', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA31D),
                  ),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              enabled: isEditing,
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(
      String label, TextEditingController controller, bool isEditing, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: isEditing
                  ? () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          controller.text = pickedTime.format(context);
                        });
                      }
                    }
                  : null,
              child: AbsorbPointer(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

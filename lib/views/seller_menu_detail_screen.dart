import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/menu_model.dart';
import '../viewmodels/menu_viewmodel.dart';
import 'seller_add_menu_screen.dart';

class SellerMenuDetailScreen extends StatefulWidget {
  final String category;

  const SellerMenuDetailScreen({Key? key, required this.category}) : super(key: key);

  @override
  _SellerMenuDetailScreenState createState() => _SellerMenuDetailScreenState();
}

class _SellerMenuDetailScreenState extends State<SellerMenuDetailScreen> {
  final MenuViewModel _viewModel = MenuViewModel();
  bool _isFABExpanded = false;
  bool _isDeleteMode = false;
  final Set<String> _selectedMenuIds = {};
  String? sellerUid;

  @override
  void initState() {
    super.initState();
    _getSellerUid();
  }

  Future<void> _getSellerUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        sellerUid = user.uid;
      });
    }
  }

  void _toggleFABMenu() {
    setState(() {
      _isFABExpanded = !_isFABExpanded;
    });
  }

  Future<void> _deleteSelectedMenus(List<MenuModel> menus) async {
    if (_selectedMenuIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada menu yang dipilih untuk dihapus.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus menu yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        for (var id in _selectedMenuIds) {
          final menu = menus.firstWhere((menu) => menu.id == id);
          await _viewModel.deleteMenu(menu.id, menu.imageUrl);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu yang dipilih berhasil dihapus.')),
        );
        setState(() {
          _selectedMenuIds.clear();
          _isDeleteMode = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus menu: $e')),
        );
      }
    }
  }

  Future<void> _editMenu(MenuModel menu) async {
    final updatedMenu = await showDialog<MenuModel>(
      context: context,
      builder: (context) => _EditMenuDialog(menu: menu),
    );

    if (updatedMenu != null) {
      try {
        await _viewModel.updateMenu(menu.id, updatedMenu);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu berhasil diperbarui.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui menu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: Text(
          widget.category,
          style: const TextStyle(
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
        actions: [
          if (_isDeleteMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                final menus = await _viewModel.fetchMenusByCategory(widget.category);
                _deleteSelectedMenus(menus);
              },
            ),
        ],
      ),
      body: sellerUid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<MenuModel>>(
              stream: _viewModel.streamMenusByCategoryAndSeller(widget.category, sellerUid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada menu tersedia.'));
                } else {
                  final menus = snapshot.data!;
                  return ListView.separated(
                    itemCount: menus.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.grey),
                    itemBuilder: (context, index) {
                      final menu = menus[index];
                      final isSelected = _selectedMenuIds.contains(menu.id);
                      return ListTile(
                        leading: _isDeleteMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedMenuIds.add(menu.id);
                                    } else {
                                      _selectedMenuIds.remove(menu.id);
                                    }
                                  });
                                },
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(menu.imageUrl),
                                radius: 30,
                              ),
                        title: Text(
                          menu.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stok: ${menu.stock}', style: const TextStyle(fontSize: 14)),
                            Text(
                              'Rp ${menu.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 14, color: Colors.green),
                            ),
                          ],
                        ),
                        trailing: _isDeleteMode
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () {
                                  _editMenu(menu);
                                },
                              ),
                        onTap: _isDeleteMode
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedMenuIds.remove(menu.id);
                                  } else {
                                    _selectedMenuIds.add(menu.id);
                                  }
                                });
                              }
                            : null,
                        onLongPress: () {
                          setState(() {
                            _isDeleteMode = true;
                            _selectedMenuIds.add(menu.id);
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
      floatingActionButton: Stack(
        children: [
          if (_isFABExpanded)
            Positioned(
              bottom: 90,
              right: 16,
              child: Container(
                width: 137,
                height: 234,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add, color: Color(0xFFFFA31D)),
                      title: const Text('Tambah'),
                      onTap: () {
                        _toggleFABMenu();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMenuScreen(category: widget.category),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Color(0xFFFFA31D)),
                      title: const Text('Hapus'),
                      onTap: () {
                        _toggleFABMenu();
                        setState(() {
                          _isDeleteMode = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleFABMenu,
              backgroundColor: const Color(0xFFFFA31D),
              child: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog untuk mengedit menu
class _EditMenuDialog extends StatelessWidget {
  final MenuModel menu;

  const _EditMenuDialog({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: menu.name);
    final stockController = TextEditingController(text: menu.stock.toString());
    final priceController = TextEditingController(text: menu.price.toString());

    return AlertDialog(
      title: const Text('Edit Menu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama Menu'),
          ),
          TextFormField(
            controller: stockController,
            decoration: const InputDecoration(labelText: 'Stok'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: priceController,
            decoration: const InputDecoration(labelText: 'Harga'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedMenu = MenuModel(
              id: menu.id,
              name: nameController.text,
              category: menu.category,
              stock: int.tryParse(stockController.text) ?? menu.stock,
              price: double.tryParse(priceController.text) ?? menu.price,
              imageUrl: menu.imageUrl,
              uid: menu.uid,
              canteenId: menu.canteenId,
              canteenName: menu.canteenName,
            );
            Navigator.pop(context, updatedMenu);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

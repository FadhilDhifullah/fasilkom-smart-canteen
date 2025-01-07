import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/menu_model.dart';
import 'dart:io';
class MenuViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<MenuModel>> streamMenusByCategory(String category) {
    return _firestore
        .collection('menus')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MenuModel>> streamMenusByCategoryAndSeller(String category, String sellerUid) {
    return _firestore
        .collection('menus')
        .where('category', isEqualTo: category)
        .where('uid', isEqualTo: sellerUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<List<MenuModel>> fetchMenusByCategory(String category) async {
    final querySnapshot = await _firestore
        .collection('menus')
        .where('category', isEqualTo: category)
        .get();
    return querySnapshot.docs
        .map((doc) => MenuModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addMenu(MenuModel menu) async {
    await _firestore.collection('menus').add(menu.toFirestore());
  }

  Future<void> updateMenu(String id, MenuModel menu) async {
    await _firestore.collection('menus').doc(id).update(menu.toFirestore());
  }

  Future<void> deleteMenu(String id, String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        await _deleteImageFromStorage(imageUrl);
      }
      await _firestore.collection('menus').doc(id).delete();
    } catch (e) {
      throw 'Error deleting menu: $e';
    }
  }

  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Error deleting image from storage: $e';
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = _storage.ref().child('menu_images/$fileName');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }
}

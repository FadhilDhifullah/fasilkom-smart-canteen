import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SellerNotificationScreen extends StatefulWidget {
  final String canteenId;

  const SellerNotificationScreen({Key? key, required this.canteenId})
      : super(key: key);

  @override
  _SellerNotificationScreenState createState() =>
      _SellerNotificationScreenState();
}

class _SellerNotificationScreenState extends State<SellerNotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _configureFirebaseListeners();
  }

  void _configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _addNotificationLog(
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? 'Ada notifikasi baru.',
        );
      }
    });
  }

  Future<void> _addNotificationLog({
    required String title,
    required String body,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'canteenId': widget.canteenId,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Gagal menyimpan notifikasi: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchNotifications() {
    return _firestore
        .collection('notifications')
        .where('canteenId', isEqualTo: widget.canteenId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Penjual'),
        backgroundColor: const Color(0xFF5DAA80),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada notifikasi.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final timestamp = notification['timestamp']?.toDate();

              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(notification['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification['body']),
                    if (timestamp != null)
                      Text(
                        '${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

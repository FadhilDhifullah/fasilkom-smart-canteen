import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../viewmodels/review_viewmodel.dart';

class SellerReviewScreen extends StatefulWidget {
  final String canteenId;
  final String sellerProfileImage;

  const SellerReviewScreen({
    Key? key,
    required this.canteenId,
    required this.sellerProfileImage,
  }) : super(key: key);

  @override
  _SellerReviewScreenState createState() => _SellerReviewScreenState();
}

class _SellerReviewScreenState extends State<SellerReviewScreen> {
  final ReviewViewModel _viewModel = ReviewViewModel();
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  String canteenName = 'Kantin';
  String sellerProfileImage = '';

  @override
  void initState() {
    super.initState();
    _fetchSellerDetails();
  }

  Future<void> _fetchSellerDetails() async {
    try {
      final sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.canteenId)
          .get();

      setState(() {
        canteenName = sellerDoc.data()?['canteenName'] ?? 'Kantin';
        sellerProfileImage = sellerDoc.data()?['imageUrl'] ?? widget.sellerProfileImage;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data penjual: $e')),
      );
    }
  }

  void _showReplyDialog(ReviewModel review) {
    if (review.reply != null && review.reply!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda sudah membalas ulasan ini')),
      );
      return;
    }

    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Balas Ulasan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: replyController,
                  decoration: const InputDecoration(labelText: 'Balasan Anda'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (replyController.text.isNotEmpty) {
                          try {
                            await FirebaseFirestore.instance
                                .collection('reviews')
                                .doc(review.reviewId)
                                .update({
                              'reply': replyController.text,
                              'replyTimestamp': FieldValue.serverTimestamp(),
                              'replyProfileImage': sellerProfileImage,
                              'canteenName': canteenName,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Balasan berhasil dikirim')),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal mengirim balasan: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Balasan tidak boleh kosong')),
                          );
                        }
                      },
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text('Ulasan Pembeli',style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Cari berdasarkan nama menu...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ReviewModel>>(
              stream: _viewModel.fetchReviews(widget.canteenId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada ulasan tersedia.'));
                }

                final reviews = snapshot.data!.where((review) {
                  return review.menuName.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                review.customerProfileImage.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(review.customerProfileImage),
                                      )
                                    : const Icon(Icons.account_circle, size: 40),
                                const SizedBox(width: 8),
                                Text(
                                  review.customerName,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.menuName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < review.rating
                                      ? Colors.amber
                                      : Colors.grey,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.reviewText,
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (review.reply != null && review.reply!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    canteenName,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      sellerProfileImage.isNotEmpty
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(sellerProfileImage),
                                              radius: 15,
                                            )
                                          : const Icon(Icons.store, size: 30),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          review.reply!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            if (review.reply == null || review.reply!.isEmpty)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () => _showReplyDialog(review),
                                  child: const Text('Balas Ulasan'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

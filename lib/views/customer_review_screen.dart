import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../viewmodels/review_viewmodel.dart';

class CustomerReviewScreen extends StatefulWidget {
  final String canteenId;
  final String menuId;
  final String orderId;
  final String menuName;
  final String menuImageUrl;
  final String customerId;
  final String customerName;
  final String customerProfileImage;
  final List<dynamic> items;

  const CustomerReviewScreen({
    Key? key,
    required this.canteenId,
    required this.menuId,
    required this.orderId,
    required this.menuName,
    required this.menuImageUrl,
    required this.customerId,
    required this.customerName,
    required this.customerProfileImage,
    required this.items,
  }) : super(key: key);

  @override
  _CustomerReviewScreenState createState() => _CustomerReviewScreenState();
}

class _CustomerReviewScreenState extends State<CustomerReviewScreen> {
  final ReviewViewModel _viewModel = ReviewViewModel();
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  String? customerProfileImage;

  @override
  void initState() {
    super.initState();
    _fetchCustomerProfileImage();
  }

  Future<void> _fetchCustomerProfileImage() async {
    try {
      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .get();

      setState(() {
        customerProfileImage =
            customerDoc.data()?['profilePicture'] ?? widget.customerProfileImage;
      });
    } catch (e) {
      print('Error fetching customer profile image: $e');
      setState(() {
        customerProfileImage = widget.customerProfileImage;
      });
    }
  }

  void _showReviewDialog({ReviewModel? review}) async {
    if (review == null) {
      final reviewExists = await FirebaseFirestore.instance
          .collection('reviews')
          .where('orderId', isEqualTo: widget.orderId)
          .get();

      if (reviewExists.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan ini sudah diulas')),
        );
        return;
      }
    }

    reviewController.text = review?.reviewText ?? '';
    rating = review?.rating ?? 0;

    final String combinedMenuNames =
        widget.items.map((item) => item['menuName'] ?? '').join(', ');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review == null ? 'Tambahkan Ulasan' : 'Edit Ulasan',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Menu yang dipesan:'),
                    const SizedBox(height: 8),
                    Text(combinedMenuNames),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reviewController,
                      decoration: const InputDecoration(labelText: 'Ulasan Anda'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              rating = (rating == index + 1) ? 0 : index + 1;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: index < rating ? Colors.amber : Colors.grey,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (reviewController.text.isNotEmpty && rating > 0) {
                              final newReview = ReviewModel(
                                reviewId: '',
                                canteenId: widget.canteenId,
                                menuId: widget.menuId,
                                orderId: widget.orderId,
                                menuName: combinedMenuNames,
                                menuImageUrl: widget.menuImageUrl,
                                customerId: widget.customerId,
                                customerName: widget.customerName,
                                customerProfileImage: customerProfileImage!,
                                reviewText: reviewController.text,
                                rating: rating,
                                timestamp: DateTime.now(),
                              );
                              _viewModel.addReview(newReview);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ulasan berhasil disimpan')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Isi ulasan dan pilih rating')),
                              );
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF114232),
        title: const Text('Ulasan'),
        centerTitle: true,
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
                            Text(review.menuName, style: const TextStyle(fontSize: 14)),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < review.rating ? Colors.amber : Colors.grey,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(review.reviewText, style: const TextStyle(fontSize: 14)),
                            if (review.reply != null && review.reply!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Balasan Penjual:',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                  Row(
                                    children: [
                                      review.replyProfileImage != null
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  review.replyProfileImage!),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showReviewDialog();
        },
        backgroundColor: const Color(0xFFFFA31D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

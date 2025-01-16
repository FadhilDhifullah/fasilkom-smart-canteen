
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../viewmodels/review_viewmodel.dart';

class CustomerReviewScreen extends StatefulWidget {
  final String canteenId;
  final String? menuId; // Opsional
  final String? orderId; // Opsional
  final String? menuName; // Opsional
  final String? menuImageUrl; // Opsional
  final String? customerId; // Opsional
  final String? customerName; // Opsional
  final String? customerProfileImage; // Opsional
  final List<dynamic>? items; // Opsional
  final bool isReadOnly;

  const CustomerReviewScreen({
    Key? key,
    required this.canteenId,
    this.menuId,
    this.orderId,
    this.menuName,
    this.menuImageUrl,
    this.customerId,
    this.customerName,
    this.customerProfileImage,
    this.items,
    this.isReadOnly = true,
  }) : super(key: key);

  @override
  _CustomerReviewScreenState createState() => _CustomerReviewScreenState();
}

class _CustomerReviewScreenState extends State<CustomerReviewScreen> {
  final ReviewViewModel _viewModel = ReviewViewModel();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();
  String _searchQuery = '';
  int rating = 0;

  void _showReviewDialog({ReviewModel? review}) {
    if (widget.isReadOnly) return;

    reviewController.text = review?.reviewText ?? '';
    rating = review?.rating ?? 0;

    final String combinedMenuNames = widget.items != null && widget.items!.isNotEmpty
        ? widget.items!.map((item) => item['menuName'] ?? '').join(', ')
        : 'Tidak ada menu yang dipesan';

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
                                menuId: widget.menuId ?? '',
                                orderId: widget.orderId ?? '',
                                menuName: combinedMenuNames,
                                menuImageUrl: widget.menuImageUrl ?? '',
                                customerId: widget.customerId ?? '',
                                customerName: widget.customerName ?? 'Tidak Diketahui',
                                customerProfileImage: widget.customerProfileImage ?? '',
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
        backgroundColor: const Color(0xFF20452C),
        title: const Text('Ulasan', style: TextStyle(color: Colors.white)),
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
                                        backgroundImage: NetworkImage(review.customerProfileImage),
                                      )
                                    : const Icon(Icons.account_circle, size: 40),
                                const SizedBox(width: 8),
                                Text(
                                  review.customerName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                  const Text(
                                    'Balasan Penjual:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (review.replyProfileImage != null &&
                                          review.replyProfileImage!.isNotEmpty)
                                        CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(review.replyProfileImage!),
                                          radius: 15,
                                        )
                                      else
                                        const Icon(Icons.store, size: 30),
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
            floatingActionButton: widget.isReadOnly
          ? null
          : FloatingActionButton(
              onPressed: () => _showReviewDialog(),
              backgroundColor: const Color(0xFFFFA31D),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }
}

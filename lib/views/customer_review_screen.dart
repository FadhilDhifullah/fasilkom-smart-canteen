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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _showReviewDialog());
  }

  void _showReviewDialog({ReviewModel? review}) {
    reviewController.text = review?.reviewText ?? '';
    rating = review?.rating ?? 0;

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
                    ...widget.items.map((item) => ListTile(
                          leading: Image.network(
                            item['imageUrl'] ?? 'https://via.placeholder.com/150',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                          title: Text(item['menuName'] ?? 'Nama Menu Tidak Tersedia'),
                          subtitle: Text(
                              'x${item['quantity']} - Rp ${item['price'].toString()}'),
                        )),
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
                              if (review == null) {
                                final newReview = ReviewModel(
                                  reviewId: '',
                                  canteenId: widget.canteenId,
                                  menuId: widget.menuId,
                                  orderId: widget.orderId,
                                  menuName: widget.menuName,
                                  menuImageUrl: widget.menuImageUrl,
                                  customerId: widget.customerId,
                                  customerName: widget.customerName,
                                  customerProfileImage: widget.customerProfileImage,
                                  reviewText: reviewController.text,
                                  rating: rating,
                                  timestamp: DateTime.now(),
                                );
                                _viewModel.addReview(newReview);
                              } else {
                                _viewModel.updateReview(review.reviewId, {
                                  'reviewText': reviewController.text,
                                  'rating': rating,
                                });
                              }
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
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          review.customerProfileImage.isNotEmpty
                              ? review.customerProfileImage
                              : widget.customerProfileImage,
                        ),
                      ),
                      title: Text(review.customerName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.menuName),
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
                          Text(review.reviewText),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showReviewDialog(review: review);
                          } else if (value == 'delete') {
                            _viewModel.deleteReview(review.reviewId);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit ulasan'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus ulasan'),
                          ),
                        ],
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

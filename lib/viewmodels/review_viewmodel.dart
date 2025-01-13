import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ReviewModel>> fetchReviews(String canteenId, {String? searchQuery}) {
  Query query = _firestore
      .collection('reviews')
      .where('canteenId', isEqualTo: canteenId);

  if (searchQuery != null && searchQuery.isNotEmpty) {
    query = query.where('menuName', isEqualTo: searchQuery);
  }

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  });
}



  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').add(review.toMap());
  }

  Future<void> updateReview(String reviewId, Map<String, dynamic> updates) async {
    await _firestore.collection('reviews').doc(reviewId).update(updates);
  }

  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
}

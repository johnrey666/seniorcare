import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewPage extends StatefulWidget {
  final String userId;
  final String conversationId;

  const ReviewPage(
      {Key? key, required this.userId, required this.conversationId})
      : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _reviewId;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final review = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewerId', isEqualTo: currentUser.uid)
        .where('reviewedUserId', isEqualTo: widget.userId)
        .where('conversationId', isEqualTo: widget.conversationId)
        .get();

    if (review.docs.isNotEmpty) {
      final data = review.docs.first.data();
      setState(() {
        _reviewId = review.docs.first.id;
        _rating = data['rating'];
        _commentController.text = data['comment'];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final reviewData = {
      'reviewerId': currentUser.uid,
      'reviewedUserId': widget.userId,
      'conversationId': widget.conversationId,
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (_reviewId != null) {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(_reviewId)
          .update(reviewData);
    } else {
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);
    }

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'How satisfied are you?',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 6.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Comment (optional)',
                          labelStyle: const TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black45),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black45),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black87),
                          ),
                        ),
                        maxLines: 4,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      if (_isSubmitting)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: const Text(
                            'Submit Review',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

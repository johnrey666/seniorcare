import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllReviewPage extends StatefulWidget {
  final String userId;

  const AllReviewPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AllReviewPageState createState() => _AllReviewPageState();
}

class _AllReviewPageState extends State<AllReviewPage> {
  int selectedStarFilter = 0;

  Stream<QuerySnapshot> _getReviewsStream() {
    var reviewsQuery = FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: widget.userId);

    if (selectedStarFilter > 0) {
      reviewsQuery =
          reviewsQuery.where('rating', isEqualTo: selectedStarFilter);
    }

    return reviewsQuery.snapshots();
  }

  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAverageRating();
  }

  void _fetchAverageRating() async {
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('reviewedUserId', isEqualTo: widget.userId)
        .get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      double totalRating = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += doc['rating'];
      }

      setState(() {
        averageRating = totalRating / reviewsSnapshot.docs.length;
      });
    }
  }

  void _onStarFilterChanged(int value) {
    setState(() {
      selectedStarFilter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Average Rating:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                StarRating(
                    rating: averageRating, size: 24, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                return ChoiceChip(
                  label: index == 0
                      ? const Text('All')
                      : Text('$index ${index > 1 ? 's' : 's'}'),
                  selected: selectedStarFilter == index,
                  onSelected: (selected) {
                    _onStarFilterChanged(selected ? index : 0);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getReviewsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var reviews = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      var review =
                          reviews[index].data() as Map<String, dynamic>;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(review['reviewerId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData ||
                              !userSnapshot.data!.exists) {
                            return const SizedBox.shrink();
                          }

                          var userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          String reviewerName =
                              '${userData['firstName']} ${userData['lastName']}';
                          String profileImageUrl =
                              userData['profileImageUrl'] ?? '';

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : const AssetImage(
                                            'assets/default_avatar.png')
                                        as ImageProvider,
                                radius: 25,
                              ),
                              title: Text(reviewerName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StarRating(
                                    rating: review['rating'].toDouble(),
                                    size: 20,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(review['comment']),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 24,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(
            Icons.star,
            color: color,
            size: size,
          );
        } else if (index < rating) {
          return Icon(
            Icons.star_half,
            color: color,
            size: size,
          );
        } else {
          return Icon(
            Icons.star_border,
            color: color,
            size: size,
          );
        }
      }),
    );
  }
}

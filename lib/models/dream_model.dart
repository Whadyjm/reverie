import 'package:cloud_firestore/cloud_firestore.dart';

class Dream {
  final String dreamId;
  final String title;
  final String classification;
  final String analysis;
  final String text;
  final bool isLiked;
  final int rating;
  final DateTime timestamp;

  Dream({
    required this.dreamId,
    required this.title,
    required this.classification,
    required this.analysis,
    required this.text,
    required this.isLiked,
    required this.rating,
    required this.timestamp,
  });

  // Factory method to create a Dream object from Firestore data
  factory Dream.fromFirestore(Map<String, dynamic> data) {
    return Dream(
      dreamId: data['dreamId'] ?? '',
      title: data['title'] ?? '',
      classification: data['classification'] ?? '',
      analysis: data['analysis'] ?? '',
      text: data['text'] ?? '',
      isLiked: data['isLiked'] ?? false,
      rating: data['rating'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Method to convert a Dream object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'dreamId': dreamId,
      'title': title,
      'classification': classification,
      'analysis': analysis,
      'text': text,
      'isLiked': isLiked,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class DreamModel {
  final String dreamId;
  final String title;
  final String text;
  final String analysis;
  final String analysisStyle;
  final String classification;
  final String emotions;
  final bool isLiked;
  final int rating;
  final Timestamp timestamp;

  DreamModel({
    required this.dreamId,
    required this.title,
    required this.text,
    required this.analysis,
    required this.analysisStyle,
    required this.classification,
    required this.emotions,
    required this.isLiked,
    required this.rating,
    required this.timestamp,
  });

  factory DreamModel.fromJson(Map<String, dynamic> json) {
    return DreamModel(
      dreamId: json['dreamId'],
      title: json['title'],
      text: json['text'],
      analysis: json['analysis'],
      analysisStyle: json['analysisStyle'],
      classification: json['classification'],
      emotions: json['emotions'],
      isLiked: json['isLiked'],
      rating: json['rating'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dreamId': dreamId,
      'title': title,
      'text': text,
      'analysis': analysis,
      'analysisStyle': analysisStyle,
      'classification': classification,
      'emotions': emotions,
      'isLiked': isLiked,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}

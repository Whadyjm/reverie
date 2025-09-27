class MonthlyEmotionsModel {
  final int month;
  final String emotion;

  MonthlyEmotionsModel({required this.month, required this.emotion});

  factory MonthlyEmotionsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyEmotionsModel(month: json['month'], emotion: json['emotion']);
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'emotion': emotion};
  }
}

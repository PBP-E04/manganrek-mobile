// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) =>
    List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
  String model;
  int pk;
  Fields fields;

  Review({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  int user;
  String rumahMakan;
  String reviewName;
  int stars;
  String comments;
  DateTime visitDate;
  DateTime createdAt;

  Fields({
    required this.user,
    required this.rumahMakan,
    required this.reviewName,
    required this.stars,
    required this.comments,
    required this.visitDate,
    required this.createdAt,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        rumahMakan: json["rumah_makan"],
        reviewName: json["review_name"],
        stars: json["stars"],
        comments: json["comments"],
        visitDate: DateTime.parse(json["visit_date"]),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "rumah_makan": rumahMakan,
        "review_name": reviewName,
        "stars": stars,
        "comments": comments,
        "visit_date":
            "${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}",
        "created_at": createdAt.toIso8601String(),
      };
}

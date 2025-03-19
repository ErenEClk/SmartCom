import 'package:smart_community_ai/core/models/user_model.dart';

class IssueModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status; // Bekliyor, İşleniyor, Tamamlandı, İptal Edildi, Duyuru
  final bool isUrgent;
  final List<String> images;
  final List<CommentModel> comments;
  final UserModel reporter;
  final String createdAt;
  final String? updatedAt;
  final String reportDate; // Bildirim tarihi
  final String reportedBy; // Bildiren kişi
  final List<String>? visibleToUsers; // Duyurunun görünür olduğu kullanıcı ID'leri

  IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.isUrgent,
    required this.images,
    required this.comments,
    required this.reporter,
    required this.createdAt,
    this.updatedAt,
    required this.reportDate,
    required this.reportedBy,
    this.visibleToUsers,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    List<CommentModel> commentsList = [];
    if (json['comments'] != null) {
      commentsList = List<CommentModel>.from(
        json['comments'].map((comment) => CommentModel.fromJson(comment)),
      );
    }

    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(json['images']);
    }

    List<String>? visibleToUsersList;
    if (json['visibleToUsers'] != null) {
      visibleToUsersList = List<String>.from(json['visibleToUsers']);
    }

    final reporter = json['reporter'] != null
        ? UserModel.fromJson(json['reporter'])
        : UserModel(
            id: '',
            name: 'Bilinmeyen',
            email: '',
            role: 'user',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          );

    return IssueModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Diğer',
      status: json['status'] ?? 'Beklemede',
      isUrgent: json['isUrgent'] ?? false,
      images: imagesList,
      comments: commentsList,
      reporter: reporter,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'],
      reportDate: json['reportDate'] ?? DateTime.now().toString().substring(0, 10),
      reportedBy: json['reportedBy'] ?? reporter.name,
      visibleToUsers: visibleToUsersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'isUrgent': isUrgent,
      'images': images,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'reporter': reporter.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'reportDate': reportDate,
      'reportedBy': reportedBy,
      'visibleToUsers': visibleToUsers,
    };
  }
}

class CommentModel {
  final String id;
  final String text;
  final UserModel user;
  final String createdAt;
  final String author; // Yorum yapan kişi
  final String date; // Yorum tarihi
  final String comment; // Yorum metni

  CommentModel({
    required this.id,
    required this.text,
    required this.user,
    required this.createdAt,
    required this.author,
    required this.date,
    required this.comment,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] != null
        ? UserModel.fromJson(json['user'])
        : UserModel(
            id: '',
            name: 'Bilinmeyen',
            email: '',
            role: 'user',
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          );

    return CommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      text: json['text'] ?? '',
      user: user,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      author: json['author'] ?? user.name,
      date: json['date'] ?? DateTime.now().toString().substring(0, 10),
      comment: json['comment'] ?? json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'user': user.toJson(),
      'createdAt': createdAt,
      'author': author,
      'date': date,
      'comment': comment,
    };
  }
} 
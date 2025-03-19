import 'dart:convert';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String userId;
  final bool isRead;
  final String? relatedId;
  final String? onModel;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.userId,
    required this.isRead,
    this.relatedId,
    this.onModel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      userId: json['userId'] ?? '',
      isRead: json['isRead'] ?? false,
      relatedId: json['relatedId'],
      onModel: json['onModel'],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'userId': userId,
      'isRead': isRead,
      'relatedId': relatedId,
      'onModel': onModel,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? userId,
    bool? isRead,
    String? relatedId,
    String? onModel,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      onModel: onModel ?? this.onModel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Bildirimin tarihini formatlı olarak döndür
  String get date {
    final dateTime = DateTime.parse(createdAt);
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  // Bildirimin saatini formatlı olarak döndür
  String get time {
    final dateTime = DateTime.parse(createdAt);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
} 
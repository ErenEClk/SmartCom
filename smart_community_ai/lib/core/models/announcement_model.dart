import 'dart:convert';
import 'package:flutter/material.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final bool isImportant;
  final String createdAt;
  final String updatedAt;
  final List<String>? imageUrls;
  final List<String>? fileUrls;
  final List<String>? targetUserIds;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.isImportant = false,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls,
    this.fileUrls,
    this.targetUserIds,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isImportant: json['isImportant'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls']) 
          : null,
      fileUrls: json['fileUrls'] != null 
          ? List<String>.from(json['fileUrls']) 
          : null,
      targetUserIds: json['targetUserIds'] != null 
          ? List<String>.from(json['targetUserIds']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isImportant': isImportant,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'imageUrls': imageUrls,
      'fileUrls': fileUrls,
      'targetUserIds': targetUserIds,
    };
  }

  String get formattedDate {
    final date = DateTime.parse(createdAt);
    return '${date.day}.${date.month}.${date.year}';
  }

  String get formattedTime {
    final date = DateTime.parse(createdAt);
    return '${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}';
  }

  String get date => createdAt;

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    bool? isImportant,
    String? createdAt,
    String? updatedAt,
    List<String>? imageUrls,
    List<String>? fileUrls,
    List<String>? targetUserIds,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrls: imageUrls ?? this.imageUrls,
      fileUrls: fileUrls ?? this.fileUrls,
      targetUserIds: targetUserIds ?? this.targetUserIds,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
} 
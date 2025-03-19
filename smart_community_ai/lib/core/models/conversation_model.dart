import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? userAvatar;

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    required this.isOnline,
    this.lastSeen,
    this.userAvatar,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Kullanıcı',
      lastMessage: json['lastMessage'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
      userAvatar: json['userAvatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'userAvatar': userAvatar,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    bool? isOnline,
    DateTime? lastSeen,
    String? userAvatar,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        lastMessage,
        unreadCount,
        updatedAt,
        isOnline,
        lastSeen,
        userAvatar,
      ];
} 
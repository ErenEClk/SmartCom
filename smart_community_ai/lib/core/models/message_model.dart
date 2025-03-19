import 'package:smart_community_ai/core/models/user_model.dart';
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final MessageType type;
  final String? fileUrl;
  final Map<String, dynamic>? metadata;
  final UserModel? senderUser;
  final UserModel? receiverUser;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
    this.readAt,
    this.type = MessageType.text,
    this.fileUrl,
    this.metadata,
    this.senderUser,
    this.receiverUser,
    this.status = MessageStatus.sent,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      type: _parseMessageType(json['type']),
      fileUrl: json['fileUrl'],
      metadata: json['metadata'],
      senderUser: json['sender'] is Map 
          ? UserModel.fromJson(json['sender']) 
          : null,
      receiverUser: json['receiver'] is Map 
          ? UserModel.fromJson(json['receiver']) 
          : null,
      status: _parseMessageStatus(json['status']),
    );
  }

  static MessageType _parseMessageType(String? type) {
    if (type == null) return MessageType.text;
    
    switch (type.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'location':
        return MessageType.location;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    if (status == null) return MessageStatus.sent;
    
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'type': type.toString().split('.').last,
      'fileUrl': fileUrl,
      'metadata': metadata,
      'status': status.toString().split('.').last,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    MessageType? type,
    String? fileUrl,
    Map<String, dynamic>? metadata,
    UserModel? senderUser,
    UserModel? receiverUser,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      metadata: metadata ?? this.metadata,
      senderUser: senderUser ?? this.senderUser,
      receiverUser: receiverUser ?? this.receiverUser,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        receiverId,
        content,
        createdAt,
        isRead,
        readAt,
        type,
        fileUrl,
        metadata,
        senderUser,
        receiverUser,
        status,
      ];

  // Mesajın gönderilme zamanını formatlı olarak döndür
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  // Mesajın gönderilme tarihini formatlı olarak döndür
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}';
  }

  // Mesajın belirli bir kullanıcı tarafından gönderilip gönderilmediğini kontrol et
  bool isSentBy(String userId) {
    return senderId == userId;
  }

  // Mesajın belirli bir kullanıcıya gönderilip gönderilmediğini kontrol et
  bool isSentTo(String userId) {
    return receiverId == userId;
  }

  // Mesajın mevcut kullanıcıdan gelip gelmediğini kontrol et
  bool get isFromMe {
    // Burada normalde currentUser.id ile karşılaştırma yapılmalı
    // Ancak bu özellik sadece UI tarafında kullanılacak
    // ve MessageBubble bileşenine isMe parametresi olarak geçilecek
    return false;
  }

  // Mesajın gönderen kullanıcısını döndür
  UserModel? get sender => senderUser;
  
  // Mesajın alıcı kullanıcısını döndür
  UserModel? get receiver => receiverUser;
}

enum MessageType {
  text,
  image,
  file,
  location,
  audio,
  video,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
} 
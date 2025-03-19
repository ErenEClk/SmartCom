import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? apartmentNumber;
  final String? profileImage;
  final String createdAt;
  final String updatedAt;
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.apartmentNumber,
    this.profileImage,
    this.createdAt = '',
    this.updatedAt = '',
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'],
      address: json['address'],
      apartmentNumber: json['apartmentNumber'],
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'apartmentNumber': apartmentNumber,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? apartmentNumber,
    String? profileImage,
    String? createdAt,
    String? updatedAt,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  String get formattedLastSeen {
    if (lastSeen == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inSeconds < 60) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${lastSeen!.day}/${lastSeen!.month}/${lastSeen!.year}';
    }
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class ResidenceModel {
  final String site;
  final String block;
  final String apartment;
  final String? status;
  final String? floor;

  ResidenceModel({
    required this.site,
    required this.block,
    required this.apartment,
    this.status,
    this.floor,
  });

  factory ResidenceModel.fromJson(Map<String, dynamic> json) {
    return ResidenceModel(
      site: json['site'] ?? '',
      block: json['block'] ?? '',
      apartment: json['apartment'] ?? '',
      status: json['status'],
      floor: json['floor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site': site,
      'block': block,
      'apartment': apartment,
      'status': status,
      'floor': floor,
    };
  }
} 
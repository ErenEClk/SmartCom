import 'dart:convert';

class PaymentModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String userId;
  final String dueDate;
  final String? paidAt;
  final String? paymentDate;
  final String? category;
  final String? status;
  final String createdAt;
  final String updatedAt;

  bool get isPaid => paidAt != null || status == 'Ödendi';

  PaymentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.userId,
    required this.dueDate,
    this.paidAt,
    this.paymentDate,
    this.category,
    this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] is String)
              ? double.tryParse(json['amount']) ?? 0.0
              : json['amount'] ?? 0.0,
      userId: json['userId'] ?? '',
      dueDate: json['dueDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      paidAt: json['paidAt'],
      paymentDate: json['paymentDate'],
      category: json['category'],
      status: json['status'],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'userId': userId,
      'dueDate': dueDate,
      'paidAt': paidAt,
      'paymentDate': paymentDate,
      'category': category,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? userId,
    String? dueDate,
    String? paidAt,
    String? paymentDate,
    String? category,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      paymentDate: paymentDate ?? this.paymentDate,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
} 
/// 💰 Modelo de Donación
class DonationModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final String? message;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  const DonationModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.message,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  /// 📄 Crear desde JSON
  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'PEN',
      paymentMethod: json['paymentMethod'] ?? 'yape',
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 📝 Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// 📊 Crear copia con cambios
  DonationModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? status,
    String? transactionId,
    String? message,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return DonationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'DonationModel(id: $id, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DonationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📈 Estadísticas de donaciones
class DonationStatsModel {
  final double totalAmount;
  final int totalDonations;
  final double averageDonation;
  final Map<String, double> monthlyTotals;
  final Map<String, int> paymentMethodCounts;

  const DonationStatsModel({
    required this.totalAmount,
    required this.totalDonations,
    required this.averageDonation,
    required this.monthlyTotals,
    required this.paymentMethodCounts,
  });

  factory DonationStatsModel.fromJson(Map<String, dynamic> json) {
    return DonationStatsModel(
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalDonations: json['totalDonations'] ?? 0,
      averageDonation: (json['averageDonation'] ?? 0).toDouble(),
      monthlyTotals: Map<String, double>.from(json['monthlyTotals'] ?? {}),
      paymentMethodCounts: Map<String, int>.from(json['paymentMethodCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'totalDonations': totalDonations,
      'averageDonation': averageDonation,
      'monthlyTotals': monthlyTotals,
      'paymentMethodCounts': paymentMethodCounts,
    };
  }
}

/// 🎯 Estados de donación
enum DonationStatus {
  pending('pending', 'Pendiente', '⏳'),
  completed('completed', 'Completada', '✅'),
  failed('failed', 'Fallida', '❌'),
  cancelled('cancelled', 'Cancelada', '🚫');

  const DonationStatus(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;

  static DonationStatus fromString(String value) {
    return DonationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DonationStatus.pending,
    );
  }
}

/// 💳 Métodos de pago
enum PaymentMethod {
  yape('yape', 'Yape', '💜'),
  plin('plin', 'Plin', '💙'),
  bcp('bcp', 'BCP', '🏦'),
  interbank('interbank', 'Interbank', '🏛️'),
  other('other', 'Otro', '💳');

  const PaymentMethod(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.yape,
    );
  }
}

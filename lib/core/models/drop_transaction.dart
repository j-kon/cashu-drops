enum TransactionType { send, receive }

enum TransactionStatus { pending, success, failed }

class DropTransaction {
  final String id;
  final int amountSats;
  final TransactionType type;
  final DateTime timestamp;
  final TransactionStatus status;
  final String mintUrl;
  final String? memo;
  final String? rawToken;
  final String? rawDebugInfo;

  const DropTransaction({
    required this.id,
    required this.amountSats,
    required this.type,
    required this.timestamp,
    required this.status,
    required this.mintUrl,
    this.memo,
    this.rawToken,
    this.rawDebugInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountSats': amountSats,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'mintUrl': mintUrl,
      'memo': memo,
      'rawToken': rawToken,
      'rawDebugInfo': rawDebugInfo,
    };
  }

  factory DropTransaction.fromJson(Map<String, dynamic> json) {
    return DropTransaction(
      id: json['id'] as String,
      amountSats: json['amountSats'] as int,
      type: TransactionType.values.byName(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TransactionStatus.values.byName(json['status'] as String),
      mintUrl: json['mintUrl'] as String,
      memo: json['memo'] as String?,
      rawToken: json['rawToken'] as String?,
      rawDebugInfo: json['rawDebugInfo'] as String?,
    );
  }
}

enum ReceiptStatus { sent, delivered, read }

extension ReceiptStatusParsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }

  static ReceiptStatus fromString(String status) {
    return ReceiptStatus.values.firstWhere((item) => item.value() == status);
  }
}

class Receipt {
  String? get id => _id;
  String? _id;
  String? receiptient;
  String? messageId;
  DateTime? timestamp;
  ReceiptStatus? status;

  Receipt({
    required this.receiptient,
    required this.messageId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'receiptient': receiptient,
        'message_id': messageId,
        'status': status?.value(),
        'timestamp': timestamp,
      };

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final receipt = Receipt(
      receiptient: json['receiptient'],
      messageId: json['message_id'],
      status: ReceiptStatusParsing.fromString(json['status']),
      timestamp: json['timestamp'],
    );
    receipt._id = json['id'];
    return receipt;
  }
}

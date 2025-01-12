import 'dart:convert';

Transaction transactionFromJson(String str) =>
    Transaction.fromJson(json.decode(str));

String transactionToJson(Transaction data) => json.encode(data.toJson());

class TransactionModel {
  final List<Transaction> transactions;
  factory TransactionModel.fromJson(Map<Transaction, dynamic> json) => TransactionModel(
    transactions: List<Transaction>.from(json['transactions'].map((x) => Transaction.fromJson(x))),
  );
  TransactionModel({required this.transactions});
}

class Transaction {
  Transaction({
    this.id,
    this.cardId,
    this.employeeId,
    this.adminId,
    required this.transactionTypeId,
    required this.trxNumber,
    required this.amount,
    this.description,
    this.startDate,
    this.endDate,
    this.status,
    this.currentBalance,
    this.createdAt,
    required this.updatedAt,
    this.transactionType,
  });

  int? id;
  int? cardId;
  int? employeeId;
  int? adminId;
  int? transactionTypeId;
  String? trxNumber;
  int? amount;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  int? currentBalance;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? transactionType;

  String getTransactionType(transactionTypeId) {
    switch (transactionTypeId) {
      case 1:
        return 'Tabungan';
      case 2:
        return 'Deposito';
      case 3:
        return 'Deposito';
      case 4:
        return 'Deposito';
      case 5:
        return 'Penarikan';
      case 6:
        return 'Pinjaman';
      case 7:
        return 'Pinjaman';
      case 8:
        return 'Pinjaman';
      default:
        return '';
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        cardId: json["card_id"],
        employeeId: json["employee_id"],
        adminId: json["admin_id"],
        transactionTypeId: json["transaction_type_id"],
        trxNumber: json["trx_number"],
        amount: json["amount"] != null
            ? int.tryParse(json["amount"].toString()) ?? 0
            : 0,
        description: json["description"],
        startDate: json["start_date"] != null
            ? DateTime.tryParse(json["start_date"])
            : null,
        endDate: json["end_date"] != null
            ? DateTime.tryParse(json["end_date"])
            : null,
        status: json["status"],
        currentBalance: json["current_balance"] != null
            ? int.tryParse(json["current_balance"].toString()) ?? 0
            : 0,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: DateTime.parse(json["updated_at"]),
        transactionType: Transaction.fromJson(json)
            .getTransactionType(json["transaction_type_id"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "card_id": cardId,
        "employee_id": employeeId,
        "admin_id": adminId,
        "transaction_type_id": transactionTypeId,
        "trx_number": trxNumber,
        "amount": amount,
        "description": description,
        "start_date": startDate!.toIso8601String(),
        "end_date": endDate!.toIso8601String(),
        "status": status,
        "current_balance": currentBalance,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "transaction_type": transactionType,
      };
}

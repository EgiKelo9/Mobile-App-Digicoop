import 'dart:convert';

CardModel cardModelFromJson(String str) => CardModel.fromJson(json.decode(str));

String cardModelToJson(CardModel data) => json.encode(data.toJson());

class CardModel {
  CardModel({
    this.id,
    this.customerId,
    required this.cardNumber,
    required this.balanceTabungan,
    this.statusTabungan,
    required this.balanceDeposito,
    this.statusDeposito,
    required this.balancePinjaman,
    this.statusPinjaman,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  int? customerId;
  String? cardNumber;
  double? balanceTabungan;
  String? statusTabungan;
  double? balanceDeposito;
  String? statusDeposito;
  double? balancePinjaman;
  String? statusPinjaman;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json["id"],
        customerId: json["customer_id"],
        cardNumber: json["card_number"],
        balanceTabungan: json["balance_tabungan"] != null
            ? double.tryParse(json["balance_tabungan"].toString()) ?? 0.0
            : 0.0,
        statusTabungan: json["status_tabungan"],
        balanceDeposito: json["balance_deposito"] != null
            ? double.tryParse(json["balance_deposito"].toString()) ?? 0.0
            : 0.0,
        statusDeposito: json["status_deposito"],
        balancePinjaman: json["balance_pinjaman"] != null
            ? double.tryParse(json["balance_pinjaman"].toString()) ?? 0.0
            : 0.0,
        statusPinjaman: json["status_pinjaman"],
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "card_number": cardNumber,
        "balance_tabungan": balanceTabungan,
        "status_tabungan": statusTabungan,
        "balance_deposito": balanceDeposito,
        "status_deposito": statusDeposito,
        "balance_pinjaman": balancePinjaman,
        "status_pinjaman": statusPinjaman,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}

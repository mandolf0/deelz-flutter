// To parse this JSON data, do
//
//     final transaction = transactionFromJson(jsonString);

// ignore_for_file: unused_label

import 'dart:convert';

Transaction transactionFromJson(String str) =>
    Transaction.fromJson(json.decode(str));

String transactionToJson(Transaction data) => json.encode(data.toJson());

class Transaction {
  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.createdAt,
    this.updatedAt,
    required this.transactionDate,
    required this.permissions,
  });
  String? id;
  String? collectionId;
  String? title;
  String? description;
  Permissions? permissions;
  String? userId;
  int? transactionType;
  double? amount;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? transactionDate;

  Transaction.fromJson(Map<String, dynamic> json) {
    id:
    json['\$id'];
    collectionId:
    json['\$collection'];
    title:
    json["title"];
    description:
    json["description"];
    print(json['data']);

    permissions:
    json["\$permissions"] != null
        ? Permissions.fromJson(json['\$permissions'])
        : null;
    userId:
    json["user_id"];
    transactionType:
    json["transaction_type"];
    amount:
    json["amount"];
    createdAt:
    json["created_at"];
    updatedAt:
    json["updated_at"];
    transactionDate:
    json["transaction_date"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['\$id'] = id;
    data['\$collection'] = collectionId;
    if (permissions != null) {
      data['$permissions'] = permissions?.toJson();
    }
    data['title'] = title;
    data['description'] = description;
    data['user_id'] = userId;
    data['transaction_type'] = transactionType;
    data['amount'] = double.parse(amount.toString());
    data['transaction_date'] = transactionDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  factory Transaction.fromMap(Map<String, dynamic> json) => Transaction(
        title: json["title"],
        description: json["description"],
        userId: json["user_id"],
        transactionType: json["transaction_type"],
        amount: double.parse(json["amount"].toString()),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(int.parse(json["created_at"])),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(int.parse(json["updated_at"])),
        transactionDate: DateTime.fromMillisecondsSinceEpoch(
            int.parse(json["transaction_date"])),
        id: json["\$id"],
        permissions: Permissions.fromJson(json['\$permissions']),
        // collectionId: json["\$collection"],
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "description": description,
        "user_id": userId,
        "transaction_type": transactionType,
        "amount": amount,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "transaction_date": transactionDate,
        "\$id": id,
        // "\$read": List<dynamic>.from(read.map((x) => x)),
        // "\$write": List<dynamic>.from(write.map((x) => x)),
        "\$collection": collectionId,
      };
}

// To parse this JSON data, do
//
//     final permissions = permissionsFromJson(jsonString);

Permissions permissionsFromJson(String str) =>
    Permissions.fromJson(json.decode(str));

String permissionsToJson(Permissions data) => json.encode(data.toJson());

class Permissions {
  late List<String> read;
  late List<String> write;

  Permissions({
    required this.read,
    required this.write,
  });
  factory Permissions.fromMap(Map<String, dynamic> map) {
    return Permissions(
      read: map['read'].cast<String>(),
      write: map['write'].cast<String>(),
    );
  }

  Permissions.fromJson(Map<String, dynamic> json) {
    read = json['read'].cast<String>();
    write = json['write'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["read"] = read;
    data["write"] = write;

    return data;
  }
}

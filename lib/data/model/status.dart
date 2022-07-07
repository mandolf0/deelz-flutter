// ignore_for_file: unused_label

// import 'package:appwrite/models.dart';

import 'package:deelz/data/model/transaction.dart';

class Status {
  String? id;
  String? status;
  String? description;
  Permissions? permissions;

  Status({
    required this.id,
    required this.status,
    this.description,
    this.permissions,
  });

  Status.fromJson(Map<String, dynamic> json) {
    id:
    json['\$id'];
    status:
    json['status'];
    description:
    json['description'];

    permissions:
    json["\$permissions"] != null
        ? Permissions.fromJson(json['\$permissions'])
        : null;
  }

  factory Status.fromMap(Map<String, dynamic> json) => Status(
        id: json['\$id'],
        status: json['status'],
        description: json['description'],
        // permissions: Permissions.fromJson(json['\$permissions']),
      );
}

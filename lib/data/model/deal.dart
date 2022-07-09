// ignore_for_file: unused_label

import 'dart:convert';

import 'package:deelz/data/model/status.dart';
import 'package:deelz/data/model/transaction.dart';

class Deal {
  String? id;
  late Status statusId;
  late String customerName;
  late String phone;
  late String address;
  int? signedDate;
  int? adjusterDate;
  int? paDate;
  String? claimNo;
  String? carrierId;
  late String salesRepId;
  late Permissions? permissions;
  Deal({
    this.id,
    required this.statusId,
    required this.customerName,
    required this.phone,
    required this.address,
    this.signedDate,
    this.adjusterDate,
    this.paDate,
    this.claimNo,
    this.carrierId,
    required this.salesRepId,
    this.permissions,
  });

  Deal.fromJson(Map<String, dynamic> json) {
    id:
    json['\$id'];
    statusId:
    Status.fromJson(jsonDecode(json['ststus']));
    customerName:
    json['cust_name'];
    phone:
    json['phone'];
    address:
    json['address'];

    signedDate:
    json['signed_date'];
    paDate:
    json['pa_date'];
    // DateTime.fromMillisecondsSinceEpoch(int.parse(json['pa_date']));
    adjusterDate:
    json['adjusters_date'];

    claimNo:
    json['claim_no'] ?? '';
    carrierId:
    json['carrier_id'] ?? '';
    salesRepId:
    json['sales_rep_id'];
    permissions:
    json["\$permissions"] != null
        ? Permissions.fromJson(jsonDecode(json['\$permissions']))
        : null;
    statusId:
    Status.fromJson(json['status']);
  }
  factory Deal.fromMap(Map<String, dynamic> map) {
    // print('printing status from json');
    // Status s = Status.fromJson(jsonDecode(map['ststus']));
    // print(s.status);

    return Deal(
      id: map['\$id'],
      statusId: map['status_id'],
      // statusId: Status.fromMap(jsonDecode(map['ststus'])),
      customerName: map['cust_name'],
      phone: map['phone'],
      address: map['address'],
      signedDate: map["signed_date"],
      paDate: map['pa_date'],

      // map['signed_date'] ?? '',
      adjusterDate: map["adjusters_date"],

      claimNo: map['claim_no'] ?? '',
      carrierId: map['carrier_id'] ?? '',
      salesRepId: map['sales_rep_id'],
      permissions: map["\$permissions"] != null
          ? Permissions.fromMap((map['\$permissions']))
          : null,
    );
  }
}

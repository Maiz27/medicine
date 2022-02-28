// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Pharmacy {
  String id;
  String name;
  String pharmcistId;
  String tele;
  double lat;
  double lng;
  Timestamp dateCreated;

  Pharmacy(
      {required this.id,
      required this.name,
      required this.pharmcistId,
      required this.tele,
      required this.lat,
      required this.lng,
      required this.dateCreated});

  factory Pharmacy.fromJson(Map<dynamic, dynamic> json) {
    return Pharmacy(
      id: json['id'],
      name: json['Pharmacy name'],
      tele: json['telephone'],
      pharmcistId: json['pharmacistId'],
      lat: json['Lat'],
      lng: json['Lng'],
      dateCreated: json['dateCreated'],
    );
  }
}

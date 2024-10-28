import 'package:flutter/foundation.dart';

class Car {
  final int id;
  final DateTime creationDate;
  final int numeroVoiture;
  final String name;
  final String plateNumber;
  final String image;
  final bool isDeleted;
  final String userId;
  final String gpsdevice;

  Car({
    required this.id,
    required this.creationDate,
    required this.numeroVoiture,
    required this.name,
    required this.plateNumber,
    required this.image,
    required this.isDeleted,
    required this.userId,
    required this.gpsdevice,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as int,
      creationDate: DateTime.parse(json['creation_date'] as String),
      numeroVoiture: json['numero_voiture'] as int,
      name: json['name'] as String,
      plateNumber: json['plate_number'] as String,
      image: json['image'] as String,
      isDeleted: json['is_deleted'] as bool,
      userId: json['user_id'] as String,
      gpsdevice: json['gpsdevice'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creation_date': creationDate.toIso8601String(),
      'numero_voiture': numeroVoiture,
      'name': name,
      'plate_number': plateNumber,
      'image': image,
      'is_deleted': isDeleted,
      'user_id': userId,
      'gpsdevice': gpsdevice,
    };
  }
}

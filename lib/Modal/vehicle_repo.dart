import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  String modal;
  int seat;
  String feat;
  final String id;
  List<DocumentReference>? ride;

  Vehicle(
      {required this.id,
      required this.modal,
      required this.seat,
      required this.feat,
      this.ride});

  Map<String, dynamic> toMap() {
    return {'id': id, 'modal': modal, 'seat': seat, 'feat': feat, 'ride': ride};
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
        id: map['id'],
        modal: map['modal'],
        seat: map['seat'],
        feat: map['feat'],
        ride: List<DocumentReference>.from(map['ride'] ?? []));
  }

  static final firestore = FirebaseFirestore.instance.collection('Vehicle');

  static Future<DocumentReference?> addVehicle(Vehicle vehi) async {
    try {
      await firestore.doc(vehi.id).set(vehi.toMap());
      return firestore.doc(vehi.id);
    } catch (e) {
      print("ERROR ADDVHICLE: $e");
      return null;
    }
  }

  static Future<Vehicle?> getVehicle(String vehiId) async {
    try {
      final vehimap = await firestore.doc(vehiId).get();
      return Vehicle.fromMap(vehimap.data()!);
    } catch (e) {
      print('ERROR GETVEHICLE: $e');
      return null;
    }
  }
}

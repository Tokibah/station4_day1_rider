import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wsmb24/Modal/vehicle_repo.dart';

class Ride {
  final String id;
  DateTime date;
  String origin;
  String destination;
  String fee;

  Ride(
      {required this.id,
      required this.date,
      required this.origin,
      required this.destination,
      required this.fee});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toString(),
      'origin': origin,
      'destination': destination,
      'fee': fee
    };
  }

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
        id: map['id'],
        date: DateTime.parse(map['date']),
        origin: map['origin'],
        destination: map['destination'],
        fee: map['fee']);
  }

  static final firestore = FirebaseFirestore.instance.collection('Ride');

  static void addRide(Ride newRide, Vehicle vehi) async {
    try {
      await firestore.doc(newRide.id).set(newRide.toMap());
      await FirebaseFirestore.instance
          .collection('Vehicle')
          .doc(vehi.id)
          .update({
        'ride': FieldValue.arrayUnion([firestore.doc(newRide.id)])
      });
    } catch (e) {
      print("ERRROR ADDRIDE: $e");
    }
  }

  static Future<List<Ride>> getRide(List<DocumentReference>? refList) async {
    try {
      List<Ride> rideList = [];
      if (refList != null) {
        for (var ref in refList) {
          final map = await firestore.doc(ref.id).get();
          rideList.add(Ride.fromMap(map.data()!));
        }
      }
      return rideList;
    } catch (e) {
      print("ERROR GETRIDE: $e");
      return [];
    }
  }

  static void updateRide(Ride ride) async {
    try {
      await firestore.doc(ride.id).update(ride.toMap());
    } catch (e) {
      print('ERROR UPDATERIDE: $e');
    }
  }

  static void deleteRide(DocumentReference rideId, Vehicle vehi) async {
    try {
      await firestore.doc(rideId.id).delete();

      await FirebaseFirestore.instance
          .collection('Vehicle')
          .doc(vehi.id)
          .update({
        'ride': FieldValue.arrayRemove([rideId])
      });
    } catch (e) {
      print('ERRROS DELETERIDE: $e');
    }
  }
}

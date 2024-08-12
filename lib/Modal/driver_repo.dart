import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Driver {
  String name;
  String gender;
  final String ic;
  String pass;
  final String email;
  final String phone;
  String address;
  String? image;
  final String id;
  DocumentReference? vehicle;

  Driver(
      {required this.gender,
      required this.name,
      required this.ic,
      required this.pass,
      required this.email,
      required this.phone,
      required this.address,
      this.image,
      required this.id,
      this.vehicle});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'ic': ic,
      'pass': pass,
      'email': email,
      'phone': phone,
      'address': address,
      'image': image,
      'id': id,
      'vehicle': vehicle
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
        gender: map['gender'],
        name: map['name'],
        ic: map['ic'],
        pass: map['pass'],
        email: map['email'],
        phone: map['phone'],
        address: map['address'],
        id: map['id'],
        image: map['image'],
        vehicle: map['vehicle']);
  }

  static final firestore = FirebaseFirestore.instance.collection("Driver");

  static Future<bool> isDupli(String icNum, String phoNum) async {
    try {
      final que = [
        firestore.where('ic', isEqualTo: icNum).get(),
        firestore.where('phone', isEqualTo: phoNum).get()
      ];

      final snap = await Future.wait(que);

      return snap.any((que) => que.docs.isNotEmpty);
    } catch (e) {
      print("ERROR ISDUPLI: $e");
      return false;
    }
  }

  static void addDriver(Driver dri) async {
    try {
      final byte = utf8.encode(dri.pass);
      final hash = sha224.convert(byte).toString();

      dri.pass = hash;
      await firestore.doc(dri.id).set(dri.toMap());
    } catch (e) {
      print("ERROR ADDDRIVER: $e");
    }
  }

  static uploadPhoto(Driver dri, File imagefile) async {
    try {
      if (dri.image != null) {
        await FirebaseStorage.instance.refFromURL(dri.image!).delete();
      }

      final uploadTask = await FirebaseStorage.instance
          .ref("images/${DateTime.now().microsecondsSinceEpoch}.jpg")
          .putFile(imagefile);

      final url = await uploadTask.ref.getDownloadURL();
      await firestore.doc(dri.id).update({'image': url});
    } catch (e) {
      print("ERROR ADDPHOTO: $e");
    }
  }

  static Future<Driver?> getDriver(String label) async {
    try {
      final userRef = await firestore.doc(label).get();
      if (userRef.exists) {
        return Driver.fromMap(userRef.data()!);
      }
      return null;
    } catch (e) {
      print("ERROR GETDRIVER: $e");
      return null;
    }
  }

  static Future<Driver?> login(String icNum, String password) async {
    try {
      final byte = utf8.encode(password);
      final hash = sha224.convert(byte).toString();

      final userSnap = await firestore
          .where('ic', isEqualTo: icNum)
          .where('pass', isEqualTo: hash)
          .get();

      Driver? user = await Driver.getDriver(userSnap.docs.first.id);

      if (user != null) {
        final pref = await SharedPreferences.getInstance();
        await pref.setString('token', user.id);
      }

      return user;
    } catch (e) {
      print("ERROR LOGN: $e");
      return null;
    }
  }
}

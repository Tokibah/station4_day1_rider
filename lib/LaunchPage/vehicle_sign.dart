import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:wsmb24/LaunchPage/launch_screen.dart';
import 'package:wsmb24/Modal/driver_repo.dart';
import 'package:wsmb24/Modal/vehicle_repo.dart';
import 'package:wsmb24/main.dart';

class VehicleSign extends StatefulWidget {
  const VehicleSign({super.key, required this.driver, required this.image});

  final Driver driver;
  final File image;

  @override
  State<VehicleSign> createState() => _VehicleSignState();
}

class _VehicleSignState extends State<VehicleSign> {
  final _formkey = GlobalKey<FormState>();

  final _modal = TextEditingController();
  double _seat = 2;
  final _feat = TextEditingController();

  Widget textfield(
      {required String label, required TextEditingController control}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 20.r),
        ),
        TextFormField(
          decoration: const InputDecoration(
              fillColor: Colors.white, border: OutlineInputBorder()),
          controller: control,
          validator: (value) => value!.isEmpty ? "Dont leave it empty" : null,
        )
      ],
    );
  }

  void registerUser() async {
    if (_formkey.currentState!.validate()) {
      final tempVehi = Vehicle(
          id: Label.getLabel(),
          modal: _modal.text,
          seat: _seat.toInt(),
          feat: _feat.text);

      final tempRRef = await Vehicle.addVehicle(tempVehi);

      widget.driver.vehicle = tempRRef;
      Driver.addDriver(widget.driver);
      await Driver.uploadPhoto(widget.driver, widget.image);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LaunchScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle information'),
      ),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Column(
              children: [
                SizedBox(height: 100.h),
                Padding(
                  padding: EdgeInsets.all(8.h),
                  child: textfield(label: 'Car Modal', control: _modal),
                ),
                const Text('Seat capacity'),
                Text(_seat.round().toString()),
                Slider(
                  inactiveColor: Colors.grey,
                  min: 2,
                  max: 100,
                  divisions: 98,
                  label: _seat.round().toString(),
                  value: _seat,
                  onChanged: (value) {
                    setState(() {
                      _seat = value;
                    });
                  },
                ),
                TextField(
                  controller: _feat,
                  maxLines: 5,
                  decoration: const InputDecoration(
                      hintText: "Speacial features (eg. Wheelchair)",
                      border: OutlineInputBorder()),
                ),
                Padding(
                  padding: EdgeInsets.all(5.h),
                  child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: ThemeProvider.trust),
                      onPressed: registerUser, child: const Text('REGISTER')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

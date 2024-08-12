import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wsmb24/LaunchPage/vehicle_sign.dart';
import 'package:wsmb24/Modal/driver_repo.dart';
import 'package:wsmb24/main.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int currSep = 0;
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _ic = TextEditingController();
  final _pass = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  File? _filed;

  @override
  void initState() {
    super.initState();
    reqPermi();
  }

  void reqPermi() async {
    await [Permission.mediaLibrary, Permission.camera].request();
  }

  Widget textfield(
      {required String label,
      required TextEditingController control,
      required Function(String) valid}) {
    return TextFormField(
      controller: control,
      decoration: InputDecoration(hintText: label),
      validator: (value) => valid(value!),
    );
  }

  void pickImage(bool isCam) async {
    final tempref = await ImagePicker()
        .pickImage(source: isCam ? ImageSource.camera : ImageSource.gallery);
    if (tempref != null) {
      _filed = File(tempref.path);
      setState(() {});
    }
  }

  void submitUser() async {
    if (await Driver.isDupli(_ic.text, _phone.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone or ic alreedy exist...')));
    } else if (_filed == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please choose an image..')));
    } else {
      final last = _ic.text.substring(_ic.text.length - 1);
      String gender = int.parse(last) % 2 == 0 ? 'Female' : 'Male';

      final newDriver = Driver(
          gender: gender,
          name: _name.text,
          ic: _ic.text,
          pass: _pass.text,
          email: _email.text,
          phone: _phone.text,
          address: _address.text,
          id: Label.getLabel());

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VehicleSign(driver: newDriver, image: _filed!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User information'),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stepper(
                currentStep: currSep,
                onStepContinue: () {
                  switch (currSep) {
                    case (0):
                      {
                        if (_formkey.currentState!.validate()) {
                          currSep += 1;
                        }
                        break;
                      }
                    case (1):
                      {
                        if (_formkey2.currentState!.validate()) {
                          currSep += 1;
                        }
                        break;
                      }
                    default:
                      submitUser();
                  }
                  setState(() {});
                },
                onStepCancel: () {
                  if (currSep != 0) {
                    setState(() {
                      currSep -= 1;
                    });
                  }
                },
                steps: [
                  Step(
                      title: const Icon(Icons.person),
                      content: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            textfield(
                                label: 'Name...',
                                control: _name,
                                valid: (value) => value.isNotEmpty
                                    ? null
                                    : "Please fill in your name..."),
                            textfield(
                                label: 'Ic Number...(eg 423423043074)',
                                control: _ic,
                                valid: (value) =>
                                    RegExp(r'[^\D]').hasMatch(value) &&
                                            value.length == 12
                                        ? null
                                        : "Invalid Ic number..."),
                            textfield(
                                label: 'Password...',
                                control: _pass,
                                valid: (value) => value.isNotEmpty
                                    ? null
                                    : "Please fill in your password...")
                          ],
                        ),
                      )),
                  Step(
                      title: const Row(children: [Icon(Icons.email), Icon(Icons.phone)],),
                      content: Form(
                          key: _formkey2,
                          child: Column(
                            children: [
                              textfield(
                                  label: 'Email...(eg eam@gmail)',
                                  control: _email,
                                  valid: (value) =>
                                      RegExp(r'.+@.+').hasMatch(value)
                                          ? null
                                          : "Invalid email address..."),
                              textfield(
                                  label: 'Phone number...(eg +345353523)',
                                  control: _phone,
                                  valid: (value) =>
                                      RegExp(r'^\+\d+').hasMatch(value) &&
                                              value.length == 12
                                          ? null
                                          : "Invalid phone number..."),
                              textfield(
                                  label: 'Address..',
                                  control: _address,
                                  valid: (value) => value.isNotEmpty
                                      ? null
                                      : "Dont leave it empty..."),
                            ],
                          ))),
                  Step(
                      title: const Icon(Icons.image),
                      content: Column(
                        children: [
                          Wrap(
                            spacing: 30,
                            children: [
                              ElevatedButton(
                                  onPressed: () => pickImage(true),
                                  child: const Text('Camera')),
                              ElevatedButton(
                                  onPressed: () => pickImage(false),
                                  child: const Text('Gallery'))
                            ],
                          ),
                          if (_filed != null)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(_filed!),
                            )
                        ],
                      ))
                ])
          ],
        ),
      ),
    );
  }
}

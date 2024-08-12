import 'package:flutter/material.dart';
import 'package:wsmb24/Modal/ride_repo.dart';
import 'package:wsmb24/Modal/vehicle_repo.dart';
import 'package:wsmb24/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Addride extends StatefulWidget {
  const Addride({super.key, required this.car, this.preRide});
  final Vehicle car;
  final Ride? preRide;

  @override
  State<Addride> createState() => _AddrideState();
}

class _AddrideState extends State<Addride> {
  final _formkey = GlobalKey<FormState>();

  DateTime? _pickDate;
  TimeOfDay? _pickTime;

  final _origin = TextEditingController();
  final _destin = TextEditingController();
  final _fee = TextEditingController(text: 'RM0.00');

  @override
  void initState() {
    super.initState();
    preData();
  }

  void preData() {
    if (widget.preRide != null) {
      _pickDate = DateTime(widget.preRide!.date.year,
          widget.preRide!.date.month, widget.preRide!.date.day);
      _pickTime = TimeOfDay(
          hour: widget.preRide!.date.hour, minute: widget.preRide!.date.minute);

      _origin.text = widget.preRide!.origin;
      _destin.text = widget.preRide!.destination;
      _fee.text = widget.preRide!.fee;
      setState(() {});
    }
  }

  Widget textfield(
      {required String label, required TextEditingController control}) {
    return Padding(
      padding: EdgeInsets.all(5.h),
      child: Column(
        children: [
          Text(label),
          TextFormField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: control,
            validator: (value) =>
                value!.isNotEmpty ? null : "Dont leave it enmpty",
          )
        ],
      ),
    );
  }

  void formatFee(String input) {
    input = input == '' ? "000" : input.replaceAll(RegExp(r'\D'), '');

    if (input.length > 3 && input.startsWith('0')) {
      input = input.replaceFirst('0', '');
    }
    if (input.length < 3) {
      input = input.padLeft(3, '0');
    }

    _fee.text =
        "RM${input.substring(0, input.length - 2)}.${input.substring(input.length - 2)}";
    setState(() {});
  }

  void submitRide() {
    if (_pickDate == null || _pickTime == null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Please set time and date properly'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'))
                ],
              ));
    } else if (_formkey.currentState!.validate()) {
      Ride tempRide = Ride(
          date: DateTime(_pickDate!.year, _pickDate!.month, _pickDate!.day,
              _pickTime!.hour, _pickTime!.minute),
          origin: _origin.text,
          destination: _destin.text,
          fee: _fee.text,
          id: widget.preRide == null ? Label.getLabel() : widget.preRide!.id);

      widget.preRide == null
          ? Ride.addRide(tempRide, widget.car)
          : Ride.updateRide(tempRide);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Column(
              children: [
                SizedBox(height: 100.h),
                Wrap(
                  spacing: 50.w,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          _pickDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030));
                          setState(() {});
                        },
                        child: Text(_pickDate == null
                            ? 'DATE'
                            : "${_pickDate!.day}/${_pickDate!.month}/${_pickDate!.year}")),
                    ElevatedButton(
                        onPressed: () async {
                          _pickTime = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          setState(() {});
                        },
                        child: Text(_pickTime == null
                            ? "TIME"
                            : _pickTime!.format(context)))
                  ],
                ),
                textfield(label: 'Origin', control: _origin),
                textfield(label: 'Destination', control: _destin),
                Text(
                  'Fee:',
                  style: TextStyle(fontSize: 20.r),
                ),
                SizedBox(
                  width: 200.w,
                  child: TextField(
                    controller: _fee,
                    textAlign: TextAlign.center,
                    onChanged: (value) => formatFee(value),
                  ),
                ),
                SizedBox(height: 50.h),
                ElevatedButton(
                  onPressed: submitRide,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.pop),
                  child: const Icon(Icons.add),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

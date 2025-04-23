import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wsmb24/MainPage/addride.dart';
import 'package:wsmb24/Modal/driver_repo.dart';
import 'package:wsmb24/Modal/ride_repo.dart';
import 'package:wsmb24/Modal/vehicle_repo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wsmb24/main.dart';

class PushHome extends StatelessWidget {
  const PushHome({super.key, required this.user});
  final Driver user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (context) => Homepage(user: user)),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.user});

  final Driver user;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isLoading = false;
  Vehicle? vehi;
  List<Ride> rideList = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    vehi = await Vehicle.getVehicle(widget.user.vehicle!.id);
    rideList = await Ride.getRide(vehi!.ride);
    setState(() {
      isLoading = false;
    });
  }

  String formatDate(DateTime date) {
    final time = TimeOfDay(hour: date.hour, minute: date.minute);
    return "${date.day}/${date.month}/${date.year} ${time.format(context)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: EdgeInsets.all(10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Addride(
                                          car: vehi!,
                                        )));

                            getUserData();
                          },
                          child: const Icon(Icons.add, color: Colors.white)),
                    ),
                    Spacer(),
                    SizedBox(
                        height: 475.h,
                        width: 370.w,
                        child: rideList.isEmpty
                            ? const Center(child: Text('No ride available'))
                            : ListView.builder(
                                itemCount: rideList.length,
                                itemBuilder: (context, index) {
                                  Ride ride = rideList[index];
                                  return Container(
                                    margin: EdgeInsets.all(5.r),
                                    decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    height: 120.h,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 100.w,
                                                      child: Center(
                                                        child: Text(
                                                          ride.origin,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons.arrow_forward),
                                                    SizedBox(
                                                      width: 100.w,
                                                      child: Center(
                                                        child: Text(
                                                          ride.destination,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const Divider(),
                                              Padding(
                                                padding: EdgeInsets.all(8.r),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                        width: 100.w,
                                                        child: Text(ride.fee,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis)),
                                                    const Spacer(),
                                                    Text(
                                                      formatDate(ride.date),
                                                      style: const TextStyle(
                                                          backgroundColor:
                                                              ThemeProvider
                                                                  .pop),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          color: ThemeProvider.honeydew,
                                          width: 90.w,
                                          child: Column(children: [
                                            IconButton(
                                                onPressed: () async {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Addride(
                                                                car: vehi!,
                                                                preRide: ride,
                                                              )));
                                                  getUserData();
                                                },
                                                icon: const Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () async {
                                                  Ride.deleteRide(
                                                      FirebaseFirestore.instance
                                                          .collection('Ride')
                                                          .doc(ride.id),
                                                      vehi!);
                                                  getUserData();
                                                },
                                                icon: const Icon(Icons.delete))
                                          ]),
                                        )
                                      ],
                                    ),
                                  );
                                }))
                  ],
                ),
              ),
            ),
    );
  }
}

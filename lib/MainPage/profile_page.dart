import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb24/LaunchPage/launch_screen.dart';
import 'package:wsmb24/Modal/driver_repo.dart';
import 'package:wsmb24/Modal/vehicle_repo.dart';
import 'package:wsmb24/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final Driver user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  Vehicle? vehi;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    vehi = await Vehicle.getVehicle(widget.user.vehicle!.id);
    setState(() {
      isLoading = false;
    });
  }

  void logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('token');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LaunchScreen()));
  }

  Widget tile({required IconData icon, required String title}) {
    return SizedBox(
      height: 50.h,
      child: Row(
        children: [
          Icon(
            icon,
            color: ThemeProvider.trust,
          ),
          Text(title)
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    Driver user = widget.user;

    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: ThemeProvider.honeydew,
                      height: 150.h,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.r),
                      child: GestureDetector(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user.image!),
                        ),
                      ),
                    ),
                    Text(user.name),
                    tile(icon: Icons.email, title: user.email),
                    tile(icon: Icons.phone, title: user.phone),
                    tile(icon: Icons.location_history, title: user.address),
                    tile(icon: Icons.person, title: user.gender),
                    const Divider(),
                    tile(
                        icon: Icons.car_repair,
                        title: "${vehi!.modal} (${vehi!.seat} seat)"),
                    SizedBox(
                        height: 70.h,
                        width: double.infinity,
                        child: Center(
                            child: Text(
                          "- ${vehi!.feat}",
                          overflow: TextOverflow.ellipsis,
                        ))),
                    GestureDetector(
                      onTap: logout,
                      child: Container(
                        height: 50.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          border: const Border.symmetric(
                              horizontal: BorderSide(width: 2)),
                        ),
                        child: Center(
                            child: Text(
                          'LOGOUT',
                          style: TextStyle(fontSize: 20.r),
                        )),
                      ),
                    )
                  ],
                ),
              ));
  }
}

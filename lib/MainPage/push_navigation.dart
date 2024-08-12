import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wsmb24/MainPage/homepage.dart';
import 'package:wsmb24/MainPage/profile_page.dart';
import 'package:wsmb24/Modal/driver_repo.dart';

class PushNavigation extends StatefulWidget {
  const PushNavigation({super.key, required this.user});
  final Driver user;

  @override
  State<PushNavigation> createState() => _PushNavigationState();
}

class _PushNavigationState extends State<PushNavigation> {
  int currIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currIndex,
        children: [PushHome(user: widget.user), ProfilePage(user: widget.user)],
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: currIndex,
          onDestinationSelected: (value) {
            setState(() {
              currIndex = value;
            });
          },
          destinations: const [
            NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.car), label: "Ride"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile")
          ]),
    );
  }
}

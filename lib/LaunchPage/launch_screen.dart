import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wsmb24/LaunchPage/sign_up.dart';
import 'package:wsmb24/MainPage/push_navigation.dart';
import 'package:wsmb24/Modal/driver_repo.dart';
import 'package:wsmb24/main.dart';

class SizeRoute extends PageRouteBuilder {
  final Widget page;
  SizeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              Align(
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          ),
        );
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  Widget build(BuildContext context) {
    final ic = TextEditingController();
    final pass = TextEditingController();

    Widget textfield(
        {required String label,
        required TextEditingController control,
        required bool obscure}) {
      return Padding(
        padding: EdgeInsets.all(5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
            ),
            TextFormField(
              obscureText: obscure,
              controller: control,
              decoration: const InputDecoration(
                  fillColor: ThemeProvider.light,
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide())),
            ),
          ],
        ),
      );
    }

    void loginUser() async {
      Driver? user = await Driver.login(ic.text, pass.text);

      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid account...')));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PushNavigation(user: user)));
      }
    }

    return Scaffold(
      backgroundColor: ThemeProvider.honeydew,
      body: Padding(
        padding: EdgeInsets.all(5.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50.h,
              ),
              SizedBox(
                width: 150.w,
                child: Text(
                  'KONSI KERETA DRIVER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30.r,
                      decorationColor: ThemeProvider.pop,
                      decorationThickness: 2,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dashed),
                ),
              ),
              FaIcon(
                FontAwesomeIcons.leaf,
                size: 150.r,
              ),
              textfield(label: 'IC. Number', control: ic, obscure: false),
              textfield(label: 'Password', control: pass, obscure: true),
              ElevatedButton(
                  onPressed: loginUser,
                  child: const Text(
                    'LOGIN',
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('dont have an account?'),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context, SizeRoute(page: const SignUp())),
                      child: const Text('Sign up')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

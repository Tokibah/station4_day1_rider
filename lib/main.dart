import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb24/MainPage/push_navigation.dart';
import 'package:wsmb24/Modal/driver_repo.dart';
import 'package:wsmb24/firebase_options.dart';
import 'package:wsmb24/LaunchPage/launch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(ChangeNotifierProvider(
        create: (context) => ThemeProvider(), child: const MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  Driver? user;

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  void checkToken() async {
    final pref = await SharedPreferences.getInstance();
    String? userId = pref.getString('token');
    if (userId != null) {
      user = await Driver.getDriver(userId);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 732),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context)._themedata,
        home: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (user == null ? const LaunchScreen() : PushNavigation(user: user!)),
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  final ThemeData _themedata = _lightMode;
  get themeData => _themedata;

  static const Color highlight = Color.fromARGB(255, 62, 202, 66);
  static const Color trust = Color.fromARGB(255, 131, 184, 228);
  static const Color pop = Color.fromARGB(255, 255, 208, 0);
  static const Color honeydew = Color.fromARGB(255, 218, 241, 219);
  static const Color light = Color.fromARGB(255, 226, 223, 223);

  static final ThemeData _lightMode = ThemeData(
      iconTheme: const IconThemeData(color: highlight),
      textTheme: GoogleFonts.montserratTextTheme(
          const TextTheme(bodyMedium: TextStyle(color: Colors.black))),
      useMaterial3: true,
      scaffoldBackgroundColor: light,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: highlight , foregroundColor: Colors.black)),
      colorScheme: const ColorScheme.light(
          primary: highlight,
          secondary: highlight,
          tertiary: trust,
          surface: light));
}

class Label {
  static String getLabel() {
    final head = WordPair.random();
    final tail = Random().nextInt(100);
    return "$head$tail";
  }
}

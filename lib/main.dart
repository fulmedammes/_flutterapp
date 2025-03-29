
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool showWelcome = prefs.getBool('already_launched') ?? true;

  runApp(MyApp(showWelcome: showWelcome));
}

class MyApp extends StatelessWidget {
  final bool showWelcome;

  const MyApp({Key? key, required this.showWelcome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My PWA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: showWelcome ? const WelcomeScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

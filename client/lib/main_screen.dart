import 'package:flutter/material.dart';
import 'package:mindonglody/home_screen.dart';
import 'package:mindonglody/recorder_screen.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatelessWidget {
  static const String id = 'home_screen';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MainScreen.id,
      routes: <String, WidgetBuilder>{
        HomeScreen.id: (context) => HomeScreen(),
        RecorderScreen.id: (context) => RecorderScreen(),
      },
    );
  }
}

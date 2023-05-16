import 'package:flutter/material.dart';
import 'package:flutterfirstproject/screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MaterialApp(
        home: HomeScreen(),
      )
  );
}

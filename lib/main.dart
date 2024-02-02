import 'package:flutter/material.dart';
import 'package:smarthealth/screen/splashScreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreenPage(), // Show splash screen initially
    );
  }
}

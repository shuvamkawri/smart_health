import 'package:flutter/material.dart';
import 'Screen2.dart'; // Import the screen2.dart file

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set your desired background color
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image1.jpeg'), // Set the image path
                  fit: BoxFit.cover, // Cover the entire container
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 70, // Adjust the vertical position
            left: 165, // Adjust the horizontal position
            child: GestureDetector(
              onTap: () {
                // Navigate to Screen2 when the slider icon is pressed
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Screen2()),
                );
              },
              child: Container(
                width: 60, // Adjust the width of the slider icon
                height: 60, // Adjust the height of the slider icon
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/nextt.png', // Set the image asset path
                  // color: Colors.white, // Set the color of the icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

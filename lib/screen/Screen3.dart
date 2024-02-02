import 'package:flutter/material.dart';
import 'Screen2.dart'; // Import the screen2.dart file
import 'Screen4.dart';

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // If the user swipes from right to left (forward)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Screen4()),
          );
        } else if (details.primaryVelocity! > 0) {
          // If the user swipes from left to right (backward)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Screen2()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.orange, // Set your desired background color
        body: Stack(
          children: [
            Container(
              width: double.infinity, // Occupy entire screen width
              height: double.infinity, // Occupy entire screen height
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image3.jpeg'), // Set the image path
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
            Positioned(
              bottom: 74, // Adjust the vertical position
              left: 179, // Adjust the horizontal position
              child: GestureDetector(
                onTap: () {
                  // Navigate to Screen4 when the slider icon is pressed
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Screen4()),
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
      ),
    );
  }
}

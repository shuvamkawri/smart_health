import 'package:flutter/material.dart';
import 'package:smarthealth/screen/sign.dart';

class ResetDisplayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.black87,
        child: Center(
          child: CustomPaint(
            painter: EllipsePainter(),
            child: Container(
              width: 300,
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 23,
                          blurRadius: 10,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/k.png', // Replace with your asset path
                        width: 84,
                        height: 84,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your Password has been reset!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the sign-in page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()), // Replace with your sign-in page widget
                      );
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EllipsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width / 2;
    final radiusY = size.height / 1;

    canvas.drawOval(Rect.fromCenter(center: center, width: radiusX * 2.6, height: radiusY * 1.6), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

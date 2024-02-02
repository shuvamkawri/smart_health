import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/pharmacyReg.dart';
import 'package:smarthealth/screen/sign.dart';
import 'package:smarthealth/screen/up.dart';

class PharmacyInterface extends StatefulWidget {
  final String pharmacyName;
  final String address;
  final String licenseNumber;
  final String gstNumber;
  final String panNumber;
  final String email; // Add this line

  PharmacyInterface({
    required this.pharmacyName,
    required this.address,
    required this.licenseNumber,
    required this.gstNumber,
    required this.panNumber,
    required this.email, // Add this line

  });

  @override
  _PharmacyInterfaceState createState() => _PharmacyInterfaceState();
}

class _PharmacyInterfaceState extends State<PharmacyInterface> {
  String email = ''; // Initialize email as an empty string

  @override
  void initState() {
    super.initState();
    getEmailFromSharedPreferences(); // Retrieve email when the widget initializes
  }

  Future<void> getEmailFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(
        'email_id'); // Use the correct key 'email_id'
    if (storedEmail != null) {
      setState(() {
        email = storedEmail;
      });

      // Print the stored email
      print('Stored Email: $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy Interface'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pharmacy Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8.0), // Add some spacing
                  Text(
                    'Email: $email', // Display the email below the menu
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.book_online),
              title: Text('order'),
              onTap: () {
                // Add the action for the Home menu item
              },
            ),
            ListTile(
              leading: Icon(Icons.delivery_dining_rounded),
              title: Text('Delivery'),
              onTap: () {
                // Add the action for the Home menu item
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('profile'),
              onTap: () {
                // Navigate to PharmacyProfileForm when the "Profile" item is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PharmacyProfileForm(), // Replace with your actual page
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Show logout confirmation dialog
                _showLogoutConfirmationDialog(context);
              },
            ),
            // ListTile(
            //   title: Text('Email: $email'), // Display the email below the menu
            // ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Add your pharmacy information here (if needed)

            SizedBox(height: 16.0),
            // Add a grid of dashboard items here
            GridView.count(
              crossAxisCount: 2,
              // 2 items per row
              shrinkWrap: true,
              // Allow the grid to occupy only the space it needs
              physics: NeverScrollableScrollPhysics(),
              // Disable scrolling
              children: [
                CustomDashboardItem(
                  iconAsset: 'assets/pr.png',
                  label: 'Prescriptions',
                  color: Colors.cyan[500]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserPrescriptionPage()), // Replace UpPage with the actual page you want to navigate to
                    );
                  },
                ),

                CustomDashboardItem(
                  iconAsset: 'assets/profile.png',
                  label: 'Profile',
                  color: Colors.blue[400]!,
                  onTap: () {
                    // Navigate to PharmacyProfileForm when "Profile" is tapped
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PharmacyProfileForm(),
                    ));
                  },
                ),
                CustomDashboardItem(
                  iconAsset: 'assets/cart.png',
                  label: 'Orders',
                  color: Colors.deepPurpleAccent[200]!,
                  onTap: () {
                    // Add the action for the Pathology Lab dashboard item
                  },
                ),
                CustomDashboardItem(
                  iconAsset: 'assets/cart.png',
                  label: 'Delivery',
                  color: Colors.green[300]!,
                  onTap: () {
                    // Add the action for the Pathology Lab dashboard item
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Do you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                // User confirmed logout, perform logout action
                Navigator.of(context).pop(); // Close the dialog
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    // Clear user session data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);

    // Navigate back to the sign-in page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  DashboardItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 48.0,
              color: Colors.blue,
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
class CustomDashboardItem extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color color;
  final VoidCallback onTap;

  CustomDashboardItem({
    required this.iconAsset,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        color: color, // Set the background color here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              iconAsset,
              width: 48.0,
              height: 48.0,
              //color: Colors.white, // Customize icon color
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(fontSize: 18.0, color: Colors.white), // Customize text color
            ),
          ],
        ),
      ),
    );
  }
}

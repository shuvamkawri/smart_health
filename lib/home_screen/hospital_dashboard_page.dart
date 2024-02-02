import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/city.dart';
import '../screen/country.dart';
import '../screen/location.dart';
import '../screen/my.dart';
import '../screen/new.dart';
import '../screen/patients.dart';
import '../screen/dr_list.dart';
import '../screen/pharmaceuticals.dart';
import '../screen/pathology.dart';
import '../screen/health_reports.dart';
import '../screen/emergency.dart';
import '../screen/bill.dart';
import '../screen/prescriptiondoctor.dart';
import '../screen/schedule.dart';
import '../screen/setting.dart';
import '../screen/helpdesk.dart';
import '../screen/disease.dart';
import '../screen/appointment.dart';
import '../screen/iot.dart';
import '../screen/sign.dart';


class HospitalDashboardPage extends StatefulWidget {
  final String loggedInEmail;
  final String cityName;

  HospitalDashboardPage({required this.loggedInEmail, required this.cityName});

  @override
  _HospitalDashboardPageState createState() => _HospitalDashboardPageState(loggedInEmail: loggedInEmail);
}


class _HospitalDashboardPageState extends State<HospitalDashboardPage> {
  final String loggedInEmail;

  String email = ''; // Declare the 'email' variable
  List<DashboardItem> items = [];
  String selectedCity = ''; // Variable to hold the selected city

  _HospitalDashboardPageState({required this.loggedInEmail});

  @override
  void initState() {
    super.initState();
    fetchDashboardItems();
    getEmailFromSharedPreferences();
    loadSelectedCity(); // Load the selected city when the widget is initialized

  }


  Future<void> fetchDashboardItems() async {
    // Simulate fetching dashboard items from an external source
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      // Update the items list with the fetched data
      items = [
        DashboardItem(
          iconAsset: 'assets/h.png',
          label: 'Hospital',
          color: Colors.blue[600]!,
          onTap: () {
            navigateToPage(HospitalPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/tt.png',
          label: 'Treatments',
          color: Colors.purpleAccent[200]!,
          onTap: () {
            navigateToPage(TreatmentPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/d.png',
          label: 'Doctors',
          color: Colors.blue[200]!,
          onTap: () {
            navigateToPage(DrListPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/a.png',
          label: 'Appointments',
          color: Colors.teal,
          onTap: () {
            navigateToPage(NewPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/pr.png',
          label: 'Prescriptions',
          color: Colors.teal[700]!,
          onTap: () {
            navigateToPage(PrescriptionDoctorPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/medi.png',
          label: 'Pharmacy store',
          color: Colors.green,
          onTap: () {
            navigateToPage(PharmaceuticalsPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/lab.png',
          label: 'Pathology Lab',
          color: Colors.green[400]!,
          onTap: () {
            navigateToPage(PathologyPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/dig.png',
          label: 'Diagnostic instruments',
          color: Colors.cyan,
          onTap: () {
            navigateToPage(IotPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/r.png',
          label: 'My Reports',
          color: Colors.blueGrey[700]!,
          onTap: () {
            navigateToPage(HealthReportsPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/amb.png',
          label: 'Emergency',
          color: Colors.red,
          onTap: () {
            navigateToPage(EmergencyPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/set.png',
          label: 'Setting',
          color: Colors.grey,
          onTap: () {
            navigateToPage(SettingsPage());
          },
        ),
        DashboardItem(
          iconAsset: 'assets/help.png',
          label: 'Help',
          color: Colors.cyan[600]!, // Change the color for "Help" to red
          onTap: () {
            navigateToPage(HelpDeskPage());
          },
        ),
      ];
    });
  }


  void navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> getEmailFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email_id');
    if (storedEmail != null) {
      setState(() {
        email = storedEmail; // Update the 'email' variable
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Close the app when the back button is pressed
        SystemNavigator.pop();
        return true; // Return true to indicate that you've handled the back button
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text('All Medical Solutions'),

        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Account'),
                accountEmail: Text(email), // Display the logged-in email here
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_on), // Icon for city
                title: Text(
                    'City: $selectedCity'), // Display the selected city name
                // onTap: () {
                //   // Navigate to the CityPage when changing the location
                //   Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => CityPage(),
                //   ));
                // },
              ),
              ListTile(
                leading: Icon(Icons.location_city),
                title: Text('Change Location'),
                onTap: () {
                  // Navigate to the CityPage when changing the location
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CountryListPage(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('My appointments'),
                onTap: () {
                  // Navigate to the CityPage when changing the location
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MyAppointmentsPage(),
                  ));
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
            ],
          ),
        ),

        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://img.freepik.com/free-vector/medical-healthcare-blue-color_1017-26807.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: items.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16),
            childAspectRatio: 1.5,
            children: items.map(buildDashboardItem).toList(),
          ),
        ),
      ),
    );
  }


  Widget buildDashboardItem(DashboardItem item) {
    return Card(
      color: item.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Add perspective
              ..rotateX(0.3), // Rotate along the X-axis for a 3D effect
            alignment: FractionalOffset.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(item.iconAsset, width: 55, height: 55),
                SizedBox(height: 8),
                Flexible(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  // void _performLogout() async {
  //   // Clear user session data
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.remove('user_id');
  //
  //   // Navigate back to the sign-in page
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => SignInPage()),
  //   );
  // }

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

  void loadSelectedCity() async {
    selectedCity =
    await getSelectedCity(); // Fetch the selected city name from SharedPreferences
    setState(() {}); // Update the widget to reflect the selected city
  }

}
  class DashboardItem {
  final String iconAsset;
  final String label;
  final Color color;
  final VoidCallback onTap;

  DashboardItem({
    required this.iconAsset,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

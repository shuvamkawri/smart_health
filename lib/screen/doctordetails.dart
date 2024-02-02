import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/dr_list.dart' as dr_list;
import 'package:smarthealth/screen/schedule.dart';
import 'package:smarthealth/screen/view.dart';
import 'city.dart';


class DoctorDetailsPage extends StatefulWidget {
  final dr_list.Doctor doctor;

  DoctorDetailsPage({required this.doctor});

  @override
  _DoctorDetailsPageState createState() => _DoctorDetailsPageState();
}
class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
bool isBiographyExpanded = false;
  @override
  Widget build(BuildContext context) {
    String strippedBiography = widget.doctor.biography.replaceAll(RegExp(r'<[^>]*>'), '');

    return Scaffold(
      appBar: AppBar(
        title: Text(' About Doctor '),
        //backgroundColor: Colors.grey,
      ), // Set the appBar property to null to remove it
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: SingleChildScrollView( // Wrap the content in SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  // Change background color to deep blue
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.keyboard_arrow_left),
                          color: Colors.blue.shade200,
                        ),
                        CircleAvatar(
                          radius: 60.0,
                          backgroundImage: NetworkImage(widget.doctor.imageUrl),
                        ),
                        IconButton(
                          onPressed: () {
                            // Handle notification icon click
                          },
                          icon: Icon(Icons.notifications),
                          color: Colors.blue.shade200,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.doctor.name,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${widget.doctor.specialist}',
                          style: TextStyle(fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),


                    SizedBox(height: 16.0),


                  ],
                ),
              ),

              SizedBox(height: 16.0),

              // Second Card with Rounded Corners
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   ' ${doctor.specialist}',
                      //   style: TextStyle(
                      //     fontSize: 18.0,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.blue,
                      //   ),
                      // ),
                      SizedBox(height: 8.0),
                      // Text(
                      //   'Address: ${doctor.address}',
                      //   style: TextStyle(
                      //     fontSize: 16.0,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      Text(
                        '${widget.doctor.education.join(', ')}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          // Change the font size to your desired value
                          fontWeight: FontWeight
                              .normal, // Change the font weight to your desired value
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '${widget.doctor.experience} years experience',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),

                      SizedBox(height: 1.0),
                      RichText(
                        text: TextSpan(
                          text: '₹', // Rupee symbol
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' ${widget.doctor.amount}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),


                      //SizedBox(height: 2.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Center(
                          //   child: Text(
                          //     'Hospital',
                          //     style: TextStyle(
                          //       fontSize: 18.0,
                          //       fontWeight: FontWeight.normal,
                          //       color: Colors.black,
                          //     ),
                          //   ),
                          // ),

                          SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.doctor.hospitalNames
                                .asMap()
                                .entries
                                .map((entry) {
                              final int index = entry.key;
                              final String hospitalName = entry.value;
                              final List<String>? cities = widget.doctor.
                                  cities; // Get the list of cities

                              if (cities != null && index < cities.length) {
                                final String city = cities[index]; // Get the city for the hospital

                                return GestureDetector(
                                  onTap: () async {
                                    String hospitalId =widget.doctor.
                                        hospitalIds?[index] ??
                                        'N/A'; // Get the hospitalId or use 'N/A' if null
                                    print(
                                        'Hospital ID: $hospitalId'); // Print the hospital ID

                                    final selectedCity = await getSelectedCity();
                                    print('Selected City: $selectedCity');

                                    if (city == selectedCity) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewPage(
                                              hospitalId: hospitalId), // Pass the hospitalId
                                        ),
                                      );
                                    } else {
                                      // Display a pop-up message because the city doesn't match
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Location Mismatch'),
                                            content: Text(
                                                'The selected city does not match the city of this hospital.'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.local_hospital,
                                              color: Colors.grey),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              hospitalName,
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.blue,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Colors.blue),
                                          // Use the location icon
                                          SizedBox(width: 8),
                                          Text(
                                            city,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors
                                                  .black, // You can adjust the color as needed
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Container(); // Return an empty container if there's an issue with the data.
                            }).toList(),
                          )


                        ],
                      ),
                      SizedBox(height: 8.0),
                      RatingBar.builder(
                        initialRating: widget.doctor.rating,
                        minRating: 1,
                        itemSize: 24.0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemBuilder: (context, _) =>
                            Icon(
                              Icons.star,
                              color: Colors.amberAccent,
                            ),
                        onRatingUpdate: (rating) {
                          print('Doctor Rating: $rating');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),

          // Add the logic for the biography section here:
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBiographyExpanded
                        ? strippedBiography
                        : strippedBiography.substring(0, 200),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  if (strippedBiography.length > 200)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isBiographyExpanded = !isBiographyExpanded;
                        });
                      },
                      child: Text(
                        isBiographyExpanded ? 'Show Less' : 'Show More',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

              SizedBox(height: 16.0),

              // Book Appointment Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showHospitalNamesDialog(context,widget.doctor.hospitalNames, widget.doctor.hospitalIds);

                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text("Book Appointment"),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: IconButton(
            onPressed: () {
              // Handle button click here
            },
            icon: Icon(icon),
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.0),
        Text(label, style: TextStyle(color: Colors.black)),
      ],
    );
  }
  Future<void> _showHospitalNamesDialog(BuildContext context, List<String> hospitalNames, List<String> hospitalIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final selectedCity = await getSelectedCity();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Hospital'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: hospitalNames.asMap().entries.map((entry) {
              final int index = entry.key;
              final String hospitalName = entry.value;
              final String hospitalId = hospitalIds[index];

              return ListTile(
                title: Text(hospitalName),
                onTap: () async {
                  await prefs.setString('selectedHospitalId', hospitalId); // Store the selected hospital ID in shared preferences
                  print('Selected Hospital ID: $hospitalId');
                  Navigator.of(context).pop(); // Close the dialog

                  // Check if the city matches the selected city
                  final List<String>? cities = widget.doctor.cities;
                  if (cities != null && index < cities.length) {
                    final String city = cities[index];

                    if (city == selectedCity) {
                      // The city matches the selected city, navigate to the SchedulePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchedulePage(
                            doctorName: widget.doctor.name,
                            doctorId: widget.doctor.doctorId,
                            // Now use 'doctorId' property
                          ),
                        ),
                      );
                    } else {
                      // Display a pop-up message because the city doesn't match
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Location Mismatch'),
                            content: Text('The selected city does not match the city of this hospital.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

}
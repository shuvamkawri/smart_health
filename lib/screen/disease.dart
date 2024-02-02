import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/patients.dart';
import 'dart:convert';
import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';
import 'subcategory.dart';

class TreatmentPage extends StatefulWidget {
  @override
  _TreatmentPageState createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  List<TreatmentCategory> treatmentCategories = [];
  List<TreatmentCategory> filteredTreatmentCategories = [];
  bool isLoading = true;
  bool isError = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _fetchCategoryId(); // Call the function here to fetch the stored categoryId.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final url = 'https://metacare.co.in:3002/api/treatment-category/list';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final result = data['results']['result'];

        setState(() {
          treatmentCategories = result.map<TreatmentCategory>((item) {
            return TreatmentCategory(
              id: item['_id'],
              name: item['category'],
             // description: item['category_description'],
              imageUrl: 'https://metacare.co.in:3002${item['image']}',
            );
          }).toList();

          filteredTreatmentCategories = treatmentCategories;
          isLoading = false;
          isError = false;
        });

        // Print the response body here
        print('Response Body: ${response.body}');

        // Print the treatmentCategories for debugging
        print('Treatment Categories: $treatmentCategories');

        // Print the filteredTreatmentCategories for debugging
        print('Filtered Treatment Categories: $filteredTreatmentCategories');
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });

        // Print an error message for debugging
        print('Error: Request failed with status code ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
      });

      // Print the error message for debugging
      print('Error: $error');
    }
  }


  Future<List<SubCategory>> fetchSubCategories(String categoryId) async {
    final url = 'https://metacare.co.in:3002/api/treatment-category/SubCategoryList';

    final requestBody = json.encode({'category_id': categoryId});
    print('Sending POST request to: $url');
    print('Request body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Received response with status code: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final subCategoryList = data['results']['result'];

        // Store categoryId in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('categoryId', categoryId);

        final subCategories = subCategoryList.map<SubCategory>((item) {
          return SubCategory(
            name: item['sub_category'],
            description: item['sub_category_description'],
          );
        }).toList();

        print('Subcategories: $subCategories');

        return subCategories;
      } else {
        print('Failed to load subcategories');
        throw Exception('Failed to load subcategories');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Failed to load subcategories');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text('Treatments'),
        //backgroundColor: Colors.grey,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.lightBlue.shade100,
            ),
            child: Column(
              children: [
                SizedBox(height: 30),
                Container(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      // prefixIcon: IconButton(
                      //   icon: Icon(Icons.keyboard_arrow_left),
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      // ),
                      hintText: 'Search by treatments',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      alignLabelWithHint: true,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                      // suffixIcon: IconButton(
                      //   icon: Icon(Icons.notifications),
                      //   onPressed: () {
                      //     // Implement the functionality when the bell icon is pressed
                      //     // For example, show notifications or navigate to a notification page
                      //   },
                      // ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredTreatmentCategories = treatmentCategories
                            .where((category) =>
                            category.name.toLowerCase().contains(
                                value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  flex: 6,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : isError
                      ? Center(child: Text('Error fetching data'))
                      : _buildDashboardItems(),
                ),
                SizedBox(height: 10),
                _buildBottomBox(context), // Pass the context as an argument here
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDashboardItems() {
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredItemWidth = (screenWidth - 20) / 3; // Adjust the spacing and division as needed
    final itemHeight = 150.0; // Set your desired item height

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: desiredItemWidth / itemHeight,
      ),
      itemCount: filteredTreatmentCategories.length,
      itemBuilder: (context, index) {
        final category = filteredTreatmentCategories[index];
        return _buildTreatmentCategoryItem(category);
      },
    );
  }


  Widget _buildTreatmentCategoryItem(TreatmentCategory category) {
    return InkWell(
      onTap: () async {
        final categoryId = category.id;
        print('Category ID: $categoryId'); // Print the category ID

        // Store the category ID in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedCategoryID', categoryId);

        _navigateToSubCategoryList(context, categoryId);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              category.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBox(BuildContext context) {
    return SizedBox(
      height: 60, // Set the desired height here
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the HospitalDashboardPage when the home button is clicked
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    HospitalDashboardPage(
                      loggedInEmail: '', cityName: '',)));
              },
              child: Image.asset('assets/homee.png', width: 34, height: 44),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the DrListPage when the doctor icon is clicked
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DrListPage()));
              },
              child: Image.asset('assets/doctor.png', width: 34, height: 44),
            ),

            GestureDetector(
              onTap: () {
                // Navigate to the HospitalPage when the hospital icon is clicked
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HospitalPage()));
              },
              child: Image.asset('assets/hospital-bed.png', width: 40, height: 48),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the MyAppointmentsPage when the time icon is clicked
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CountryListPage()));
              },
              child: Image.asset('assets/google-maps.png', width: 34, height: 44),
            ),
          ],
        ),
      ),
    );
  }




  void _navigateToSubCategoryList(BuildContext context,
      String categoryId) async {
    try {
      List<SubCategory> subCategories = await fetchSubCategories(categoryId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoryPage(subCategories: subCategories),
        ),
      );
    } catch (error) {
      // Handle the error, e.g., show an error message to the user
    }
  }
}

class TreatmentCategory {
  final String id;
  final String name;
 //final String description;
  final String imageUrl;

  TreatmentCategory({
    required this.id,
    required this.name,
   // required this.description,
    required this.imageUrl,
  });
}
// Function to fetch categoryId from SharedPreferences
Future<void> _fetchCategoryId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? categoryId = prefs.getString('categoryId');
  if (categoryId != null) {
    print('Stored categoryId: $categoryId');
  } else {
    print('No categoryId stored in shared preferences');
  }
}

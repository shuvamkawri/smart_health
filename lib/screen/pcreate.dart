import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


class PCreateScreen extends StatelessWidget {
  Future<void> _pickImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // You can specify the file type you want to pick (e.g., image, PDF, etc.).
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Here, you can use the selected file (file.path) for further processing.
      print('Selected file path: ${file.path}');
    } else {
      // User canceled the file picking.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 5.0,
              margin: EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  // Add code to take a picture through the camera here
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.camera_alt,
                        size: 64.0,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Take a Picture',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              elevation: 5.0,
              margin: EdgeInsets.all(16.0),
              child: InkWell(
                onTap: _pickImageFromGallery, // Call the file picker function here
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.photo,
                        size: 64.0,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        '   Gallery   ',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
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

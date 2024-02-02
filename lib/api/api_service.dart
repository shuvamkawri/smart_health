import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = 'http://192.46.212.177:3025/api/user';

  static Future<Map<String, dynamic>> generateOTPByEmail(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp-generate-by-email'),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    print('Generate OTP Response: ${response.body}');

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'success': false, 'message': 'OTP generation failed.'};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String email,
      String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    final headers = {'Content-Type': 'application/json'};
    final requestBody = {'email': email, 'otp': otp};
    final requestBodyJson = jsonEncode(requestBody);

    try {
      final response = await http.post(
          url, headers: headers, body: requestBodyJson);

      print('Verify OTP Request: email = $email, otp = $otp');
      print('Verify OTP Request URL: $url');
      print('Verify OTP Request Headers: $headers');
      print('Verify OTP Request Body: $requestBodyJson');
      print('Verify OTP Response Status Code: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');

      if (response.statusCode == 201) { // Change the status code to 200
        final responseBody = json.decode(response.body);

        if (responseBody.containsKey('success')) {
          if (responseBody['success']) {
            print('OTP verification successful.');
            return responseBody;
          } else {
            throw Exception('Invalid OTP');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }
}
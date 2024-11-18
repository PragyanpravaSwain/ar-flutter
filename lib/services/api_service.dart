import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../utils/storage_keys.dart';

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Login API
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Starting login API call');
    print('Request body: {email: $email, password: $password}');
    print("api_url: $loginEndpoint");

    final response = await http.post(
      Uri.parse(loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    print('Login API Response: ${response.statusCode}');
    print('Login API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('Login successful');
      return jsonDecode(response.body);
    } else {
      print('Login failed with error: ${response.body}');
      throw jsonDecode(response.body)['errors'];
    }
  }


  // Register API
  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation, String phone) async {
    final response = await http.post(
      Uri.parse(registerEndpoint), // Define the correct endpoint for registration
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
        "phone": phone,
      }),
    );

    print('Registration Response Status Code: ${response.statusCode}');
    print('Registration Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw jsonDecode(response.body)['errors'] ?? 'Registration failed';
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final token = await _storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse(getMe),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else {
      throw Exception("Failed to fetch user details");
    }
  }

  Future<void> uploadProfilePic(String filePath) async {
    final token = await _storage.read(key: 'access_token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(uploadAvtar),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Failed to upload profile picture");
    }
  }

  // Fetch User Permissions API
  Future<List<String>> getUserPermissions(String token) async {
    print('Starting getUserPermissions API call');
    print('Token: $token');

    final response = await http.get(
      Uri.parse(permissionsEndpoint),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Permissions API Response: ${response.statusCode}');
    print('Permissions API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('Permissions fetched successfully');
      return List<String>.from(jsonDecode(response.body)['permissions']);
    } else {
      print('Failed to fetch permissions');
      throw Exception(fetchPermissionsFailedMessage);
    }
  }

  // Save tokens to secure storage
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    print('Saving tokens to secure storage');
    print('Access Token: $accessToken');
    print('Refresh Token: $refreshToken');

    await _storage.write(key: accessTokenKey, value: accessToken);
    await _storage.write(key: refreshTokenKey, value: refreshToken);

    print('Tokens saved successfully');
  }

  // Save permissions to secure storage
  Future<void> savePermissions(List<String> permissions) async {
    print('Saving permissions to secure storage');
    print('Permissions: $permissions');

    await _storage.write(key: userPermissionsKey, value: jsonEncode(permissions));

    print('Permissions saved successfully');
  }


  // Fetch User Address
  Future<Map<String, dynamic>> getUserAddress() async {
    final response = await http.get(
      Uri.parse(addressEndpoint),
      headers: {
        'Authorization': 'Bearer ${await _storage.read(key: accessTokenKey)}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {'status': 404, 'message': 'Address not found for this user'};
    } else {
      throw Exception('Failed to fetch address');
    }
  }

// Add New Address
  Future<void> addAddress(String street, String city, String state, String postalCode, String country) async {
    final response = await http.post(
      Uri.parse(addressEndpoint),
      headers: {
        'Authorization': 'Bearer ${await _storage.read(key: accessTokenKey)}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'street': street,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add address');
    }
  }

// Update Address
  Future<void> updateAddress(String addressId, String street, String city, String state, String postalCode, String country) async {
    final response = await http.put(
      Uri.parse('$addressEndpoint'),
      headers: {
        'Authorization': 'Bearer ${await _storage.read(key: accessTokenKey)}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'street': street,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update address');
    }
  }

  // Fetch skills from backend
  Future<Map<String, dynamic>> fetchSkills() async {
    print(getSkillsEndpoint);
    try {
      final response = await http.get(Uri.parse(getSkillsEndpoint), headers: {
        'Authorization': 'Bearer ${await _storage.read(key: accessTokenKey)}',
      });

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load skills');
      }
    } catch (e) {
      print('Error fetching skills: $e');
      throw e;
    }
  }

  // Add or update skills
  Future<Map<String, dynamic>> updateSkills(List<String> skillsData) async {
    try {
      final response = await http.post(
        Uri.parse(addSkillsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(skillsData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update skills');
      }
    } catch (e) {
      print('Error updating skills: $e');
      throw e;
    }
  }

  // Upload resume
  Future<Map<String, dynamic>> uploadResume(String filePath) async {
    try {
      // Get the token from storage
      final token = await _storage.read(key: 'access_token');

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(resumeSkillsEndpoint));

      // Add Authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Attach the resume file
      request.files.add(await http.MultipartFile.fromPath('resume', filePath));

      // Send the request
      var response = await request.send();

      // Check if the upload was successful
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);  // Return the response body as a map
      } else {
        throw Exception('Failed to upload resume');
      }
    } catch (e) {
      print('Error uploading resume: $e');
      throw e;
    }
  }

}

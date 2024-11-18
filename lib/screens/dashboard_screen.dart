import 'package:ar_pr_flutter/screens/skills_resume_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'address_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final details = await _apiService.getUserDetails();
      setState(() {
        userDetails = details;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user details: $error");
    }
  }

  Future<void> _uploadProfilePic() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        await _apiService.uploadProfilePic(image.path);
        _fetchUserDetails(); // Refresh details after upload
      } catch (error) {
        print("Error uploading profile picture: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: userDetails?['avatar_url'] != null
                        ? NetworkImage(userDetails!['avatar_url'])
                        : AssetImage('assets/avatar_placeholder.png')
                    as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _uploadProfilePic,
                    child: Text("Change Profile Picture"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildDetailItem("Name", userDetails?['name'] ?? ''),
            _buildDetailItem("Email", userDetails?['email'] ?? ''),
            _buildDetailItem("Phone", userDetails?['phone'] ?? ''),
            _buildDetailItem(
              "Role",
              userDetails?['role']?['name'] ?? '',
            ),
            SizedBox(height: 20),

            SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate to AddressScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressScreen()),
            );
          },
          child: Text('View/Edit Address'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navigate to AddressScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SkillsAndResumeScreen()),
            );
          },
          child: Text("View/Add Skills"),
        ),
      ],
    );
  }
}

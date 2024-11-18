import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import "./pdf_viewer_screen.dart";

class SkillsAndResumeScreen extends StatefulWidget {
  @override
  _SkillsAndResumeScreenState createState() => _SkillsAndResumeScreenState();
}

class _SkillsAndResumeScreenState extends State<SkillsAndResumeScreen> {
  bool _isLoading = false;
  List<String> _skills = [];
  String? _resumeUrl;
  final TextEditingController _skillsController = TextEditingController();

  // Create an instance of ApiService
  final ApiService _apiService = ApiService();

  // Fetch skills from the API
  Future<void> _fetchSkills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.fetchSkills();
      if (response['status'] == 200) {
        setState(() {
          _skills = List<String>.from(response['skills']['skills']);
          _resumeUrl = response['skills']['resume_url'];
        });
      } else {
        setState(() {
          _skills = [];
          _resumeUrl = null;
          _skillsController.text = '';
        });
      }
    } catch (e) {
      print('Error fetching skills: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Update skills using API
  Future<void> _updateSkills() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSkills =
      _skillsController.text.split(',').map((e) => e.trim()).toList();
      final response = await _apiService.updateSkills(updatedSkills);

      if (response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Skills updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update skills')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating skills')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Upload resume functionality
  Future<void> _uploadResume() async {
    setState(() {
      _isLoading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );
    if (result != null) {
      final file = result.files.single;
      final filePath = file.path!;

      try {
        final response = await _apiService.uploadResume(filePath);
        if (response['status'] == 200) {
          setState(() {
            _resumeUrl = response['resume_url'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resume uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload resume')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading resume')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Navigate to PDF Viewer Screen
  void _viewResume() {
    if (_resumeUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfUrl: _resumeUrl!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No resume available to view')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skills and Resume')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skills:', style: TextStyle(fontSize: 18)),
            if (_skills.isEmpty)
              Text(
                'No skills added yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ..._skills.map(
                  (skill) => Text(skill, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 16),
            // TextField(
            //   controller: _skillsController,
            //   decoration: InputDecoration(
            //     labelText: 'Update Skills (comma-separated)',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            // SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: _updateSkills,
            //   child: Text('Update Skills'),
            // ),
            SizedBox(height: 32),
            Text('Resume:', style: TextStyle(fontSize: 18)),
            if (_resumeUrl != null)
              Column(
                children: [
                  Text('Resume available for viewing'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _viewResume,
                    child: Text('Show Resume'),
                  ),
                ],
              )
            else
              Text(
                'No resume uploaded.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadResume,
              child: Text('Upload Resume'),
            ),
          ],
        ),
      ),
    );
  }
}

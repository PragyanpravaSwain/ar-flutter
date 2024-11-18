import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? address;
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      setState(() => _isLoading = true);
      final response = await _apiService.getUserAddress();
      setState(() {
        if (response['status'] == 200) {
          address = response['address'];
          _streetController.text = address!['street'];
          _cityController.text = address!['city'];
          _stateController.text = address!['state'];
          _postalCodeController.text = address!['postal_code'];
          _countryController.text = address!['country'];
          isEditMode = true;
        } else {
          isEditMode = false;
        }
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch address")));
    }
  }

  Future<void> _saveAddress() async {
    if (_streetController.text.isEmpty || _cityController.text.isEmpty || _stateController.text.isEmpty || _postalCodeController.text.isEmpty || _countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
      return;
    }

    try {
      setState(() => _isLoading = true);
      if (isEditMode) {
        // Update Address
        await _apiService.updateAddress(
          address!['id'],
          _streetController.text,
          _cityController.text,
          _stateController.text,
          _postalCodeController.text,
          _countryController.text,
        );
      } else {
        // Add New Address
        await _apiService.addAddress(
          _streetController.text,
          _cityController.text,
          _stateController.text,
          _postalCodeController.text,
          _countryController.text,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Address saved successfully")));
      _fetchAddress(); // Refresh address details
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save address")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Address")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Address")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Address if available
              if (isEditMode) ...[
                Text("Street: ${address!['street']}", style: TextStyle(fontSize: 16)),
                Text("City: ${address!['city']}", style: TextStyle(fontSize: 16)),
                Text("State: ${address!['state']}", style: TextStyle(fontSize: 16)),
                Text("Postal Code: ${address!['postal_code']}", style: TextStyle(fontSize: 16)),
                Text("Country: ${address!['country']}", style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
              ],

              // Address Form
              TextField(
                controller: _streetController,
                decoration: InputDecoration(labelText: "Street"),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City"),
              ),
              TextField(
                controller: _stateController,
                decoration: InputDecoration(labelText: "State"),
              ),
              TextField(
                controller: _postalCodeController,
                decoration: InputDecoration(labelText: "Postal Code"),
              ),
              TextField(
                controller: _countryController,
                decoration: InputDecoration(labelText: "Country"),
              ),
              SizedBox(height: 16),

              // Save Address Button
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text(isEditMode ? "Update Address" : "Add Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

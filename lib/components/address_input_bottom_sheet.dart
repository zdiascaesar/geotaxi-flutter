import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressInputBottomSheet extends StatefulWidget {
  final VoidCallback onMapButtonPressed;

  const AddressInputBottomSheet({Key? key, required this.onMapButtonPressed}) : super(key: key);

  @override
  _AddressInputBottomSheetState createState() => _AddressInputBottomSheetState();
}

class _AddressInputBottomSheetState extends State<AddressInputBottomSheet> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<Map<String, String>> _pickupSuggestions = [];
  List<Map<String, String>> _destinationSuggestions = [];

  final String mapboxAccessToken = 'YOUR_MAPBOX_ACCESS_TOKEN_HERE';
  final String mapboxEndpoint = 'https://api.mapbox.com/geocoding/v5/mapbox.places/';

  Future<List<Map<String, String>>> _getAddressSuggestions(String input) async {
    if (input.isEmpty) return [];

    final url = '$mapboxEndpoint$input.json?access_token=$mapboxAccessToken&autocomplete=true';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['features'] as List)
          .map((place) => {
                'placeName': place['place_name'] as String,
                'placeId': place['id'] as String,
              })
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  void _updateSuggestions(String input, bool isPickup) async {
    final suggestions = await _getAddressSuggestions(input);
    setState(() {
      if (isPickup) {
        _pickupSuggestions = suggestions;
      } else {
        _destinationSuggestions = suggestions;
      }
    });
  }

  Widget _buildSuggestionList(List<Map<String, String>> suggestions, bool isPickup) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]['placeName'] ?? ''),
          onTap: () {
            setState(() {
              if (isPickup) {
                _pickupController.text = suggestions[index]['placeName'] ?? '';
                _pickupSuggestions.clear();
              } else {
                _destinationController.text = suggestions[index]['placeName'] ?? '';
                _destinationSuggestions.clear();
              }
            });
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isPickup) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(Icons.location_on),
            ),
            onChanged: (value) => _updateSuggestions(value, isPickup),
          ),
        ),
        TextButton(
          onPressed: widget.onMapButtonPressed,
          child: Text('карта', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_pickupController, 'Pickup Location', true),
            if (_pickupSuggestions.isNotEmpty)
              _buildSuggestionList(_pickupSuggestions, true),
            SizedBox(height: 16),
            _buildTextField(_destinationController, 'Destination', false),
            if (_destinationSuggestions.isNotEmpty)
              _buildSuggestionList(_destinationSuggestions, false),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}
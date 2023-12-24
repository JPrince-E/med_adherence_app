// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:med_adherence_app/global.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  TextEditingController _emergencyNumberController = TextEditingController();
  final CollectionReference _emergencyContactsCollection = FirebaseFirestore
      .instance
      .collection('emergencyContacts'); // Change to your collection name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Emergency Contact Number:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emergencyNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Number',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveEmergencyContact();
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                makeEmergencyCall();
              },
              child: const Text('Call Emergency'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEmergencyContact() async {
    String emergencyNumber = _emergencyNumberController.text;

    if (_isValidPhoneNumber(emergencyNumber)) {
      try {
        // Use set with the specified document ID (currentUserId)
        await _emergencyContactsCollection.doc(currentUserID).set({
          'number': emergencyNumber,
        });

        print('Emergency contact number saved: $emergencyNumber');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency contact number saved')),
        );
      } catch (e) {
        print('Error saving emergency contact: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving emergency contact')),
        );
      }
    } else {
      print('Invalid phone number');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number')),
      );
    }
  }

  bool _isValidPhoneNumber(String number) {
    // Implement your validation logic here
    // You can use regular expressions or other methods to validate phone numbers
    // For example, you can use a regular expression like this:
    // return RegExp(r'^\d{10}$').hasMatch(number);
    return true; // For simplicity, assuming all numbers are valid
  }

  String sanitizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), ''); // Keep only digits
  }

  void makeEmergencyCall() async {
    String emergencyNumber = _emergencyNumberController.text.trim();
    if (emergencyNumber.isNotEmpty) {
      try {
        await launch('tel:$emergencyNumber');
        print('Could launch $emergencyNumber');
      } catch (e) {
        print('Error launching $emergencyNumber: $e');
        // Provide user feedback here if needed
      }
    } else {
      print('Phone number is null or empty');
      // Provide user feedback here if needed
    }
  }
}

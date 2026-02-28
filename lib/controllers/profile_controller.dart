import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadProfilePicture(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 25, // Lower quality to keep Base64 string small
        maxWidth: 400,    // Limit dimensions
      );

      if (image == null) return;

      final User? user = _auth.currentUser;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in.')),
          );
        }
        return;
      }

      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing profile picture (Free Storage)...')),
        );
      }

      // Read bytes
      final File file = File(image.path);
      final List<int> bytes = await file.readAsBytes();

      // Convert to Base64
      final String base64Image = base64Encode(bytes);
      debugPrint("Converted image to Base64. Length: ${base64Image.length}");

      if (base64Image.length > 900000) { // Firestore limit is 1MB
        throw Exception("Image is too large. Please select a smaller photo.");
      }

      // Update Firestore directly
      await _db.collection('users').doc(user.uid).update({
        'photoUrl': base64Image,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      debugPrint("Base64 Storage Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Helper to get ImageProvider from either URL or Base64 string
  static ImageProvider? getImageProvider(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    
    try {
      if (photoUrl.startsWith('http')) {
        return NetworkImage(photoUrl);
      } else {
        // Assume Base64
        return MemoryImage(base64Decode(photoUrl));
      }
    } catch (e) {
      debugPrint("Error decoding image provider: $e");
      return null;
    }
  }

  Future<void> updateProfile(BuildContext context, String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
}

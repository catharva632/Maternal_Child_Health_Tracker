import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadProfilePicture(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) return;

      final User? user = _auth.currentUser;
      if (user == null) return;

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading profile picture...')),
      );

      // Upload to Firebase Storage
      final Reference ref = _storage.ref().child('profile_pics').child('${user.uid}.jpg');
      debugPrint("Attempting upload to bucket: ${_storage.bucket}");
      debugPrint("Ref path: ${ref.fullPath}");

      // Create metadata
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // Start upload
      UploadTask uploadTask = ref.putFile(File(image.path), metadata);
      
      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = 100 * (snapshot.bytesTransferred / snapshot.totalBytes);
        debugPrint("Upload progress: ${progress.toStringAsFixed(2)}%");
      });

      // Await completion
      await uploadTask;
      debugPrint("Upload task completed successfully.");

      // Explicitly get the URL from the original ref
      String downloadUrl = await ref.getDownloadURL();
      debugPrint("Generated Download URL: $downloadUrl");

      // Update Firestore
      await _db.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      debugPrint("Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }
}

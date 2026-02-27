import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async';
import 'package:another_telephony/telephony.dart';
import '../models/patient_model.dart';
import 'contact_controller.dart';

class SOSController {
  static final SOSController _instance = SOSController._internal();
  factory SOSController() => _instance;
  SOSController._internal();

  final Telephony telephony = Telephony.instance;

  bool _isEmergencyActive = false;
  Position? _currentPosition;

  // Mock database of hospitals for the hackathon
  final List<Map<String, dynamic>> localHospitals = [
    {
      'name': 'City Care Hospital',
      'type': 'Hospital',
      'phone': '020-11111111',
      'lat': 18.5204,
      'lng': 73.8567,
    },
    {
      'name': 'Grace Maternity Clinic',
      'type': 'Clinic',
      'phone': '020-22222222',
      'lat': 18.5250,
      'lng': 73.8600,
    },
    {
      'name': 'Ruby Hall Clinic',
      'type': 'Hospital',
      'phone': '020-33333333',
      'lat': 18.5300,
      'lng': 73.8500,
    },
    {
      'name': 'Noble Hospital',
      'type': 'Hospital',
      'phone': '020-44444444',
      'lat': 18.5100,
      'lng': 73.8700,
    },
  ];

  Future<void> startSOS(PatientModel patient) async {
    if (_isEmergencyActive) return;
    _isEmergencyActive = true;

    print("--- EMERGENCY SOS INITIATED ---");

    // Fetch latest contacts from Firebase
    await ContactController().fetchContacts();

    // Step 1: Get GPS location
    try {
      _currentPosition = await _determinePosition();
      print("Step 1: GPS Fixed: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}");
    } catch (e) {
      print("GPS Error: $e");
      _isEmergencyActive = false;
      return;
    }

    String locationUrl = "https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}";
    String sosMessage = "I am in help! My Location: $locationUrl";

    // Step 2: Alert Doctor, Hospital, and Family Contacts
    // Alert Doctor
    if (patient.doctorPhone != null) {
      await _sendSMS(recipient: patient.doctorPhone!, message: sosMessage);
    }
    
    // Alert Patient's Hospital
    if (patient.hospitalPhone != null) {
      await _sendSMS(recipient: patient.hospitalPhone!, message: sosMessage);
    }

    // Alert Family Contacts
    final familyContacts = ContactController().getContacts();
    for (var contact in familyContacts) {
      await _sendSMS(recipient: contact.phone, message: sosMessage);
    }
    print("Step 2: Initial SOS alerts sent to Doctor, Hospital, and ${familyContacts.length} family contacts.");

    // Step 3: Find Nearest Hospitals using Haversine
    List<Map<String, dynamic>> sortedHospitals = _getHospitalsSortedByDistance();
    if (sortedHospitals.isEmpty) {
      print("Error: No nearby hospitals found.");
      _isEmergencyActive = false;
      return;
    }

    // Step 4: Contact First Nearest Hospital
    Map<String, dynamic> nearest = sortedHospitals.first;
    print("Step 4: Contacting nearest hospital: ${nearest['name']}");
    await _sendSMS(
      recipient: nearest['phone'],
      message: "EMERGENCY: Patient ${patient.name} needs immediate help. Location: $locationUrl. Reply YES to confirm.",
    );

    // Step 5: Wait 5 minutes for response (Simulated as 15 seconds for testing/hackathon demo)
    print("Step 5: Waiting 5 minutes (simulated) for response from ${nearest['name']}...");
    bool confirmed = await _waitForConfirmation(15); 

    if (!confirmed) {
      // Step 6: Fallback to Second Nearest Hospital
      if (sortedHospitals.length > 1) {
        Map<String, dynamic> secondNearest = sortedHospitals[1];
        print("Step 6: No response. Falling back to second nearest: ${secondNearest['name']}");
        
        await _sendSMS(
          recipient: secondNearest['phone'],
          message: "EMERGENCY: First hospital didn't respond. Patient ${patient.name} needs help. Location: $locationUrl",
        );

        // Step 7: Trajectory Update to all original contacts
        String trajectoryMsg = "UPDATE: No response from ${nearest['name']}. I am proceeding to ${secondNearest['name']}. My Location: $locationUrl. Hospital Location: https://maps.google.com/?q=${secondNearest['lat']},${secondNearest['lng']}";
        
        if (patient.doctorPhone != null) await _sendSMS(recipient: patient.doctorPhone!, message: trajectoryMsg);
        if (patient.hospitalPhone != null) await _sendSMS(recipient: patient.hospitalPhone!, message: trajectoryMsg);
        for (var contact in familyContacts) {
          await _sendSMS(recipient: contact.phone, message: trajectoryMsg);
        }
        print("Step 7: Trajectory notifications sent to all contacts.");
      }
    } else {
      print("Step 6: Emergency confirmed by ${nearest['name']}. Help is on the way.");
    }

    _isEmergencyActive = false;
    print("--- EMERGENCY SOS FLOW COMPLETED ---");
  }

  Future<bool> _waitForConfirmation(int seconds) async {
    // In a real app, this would check a database or await a webhook/push notification
    // For the demo, we simulate a timeout (false) to trigger the fallback logic.
    await Future.delayed(Duration(seconds: seconds));
    return false; // Simulation: Hospital didn't respond
  }

  Future<void> _sendSMS({required String recipient, required String message}) async {
    // Autonomous SMS implementation using Telephony
    try {
      // Telephony handles the background sending
      await telephony.sendSms(
        to: recipient,
        message: message,
        statusListener: (SendStatus status) {
          print("SMS to $recipient status: $status");
        },
      );
      print("[Telephony] Autonomous SOS sent to $recipient");
    } catch (e) {
      print("[Telephony ERROR] Failed to send to $recipient: $e");
    }
  }

  List<Map<String, dynamic>> _getHospitalsSortedByDistance() {
    if (_currentPosition == null) return localHospitals;

    for (var hospital in localHospitals) {
      hospital['distance'] = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        hospital['lat'],
        hospital['lng'],
      );
    }

    List<Map<String, dynamic>> sorted = List.from(localHospitals);
    sorted.sort((a, b) => a['distance'].compareTo(b['distance']));
    return sorted;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Radius of earth in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}

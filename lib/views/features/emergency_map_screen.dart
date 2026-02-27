import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/sos_controller.dart';
import '../../controllers/patient_controller.dart';
import '../../models/patient_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyMapScreen extends StatefulWidget {
  const EmergencyMapScreen({super.key});

  @override
  State<EmergencyMapScreen> createState() => _EmergencyMapScreenState();
}

class _EmergencyMapScreenState extends State<EmergencyMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
    _loadHospitalMarkers();
  }

  Future<void> _loadInitialLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          ),
        );
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  void _loadHospitalMarkers() {
    final hospitals = SOSController().localHospitals;
    for (var hospital in hospitals) {
      _markers.add(
        Marker(
          markerId: MarkerId(hospital['name']),
          position: LatLng(hospital['lat'], hospital['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _showHospitalPopup(hospital),
        ),
      );
    }
    setState(() {});
  }

  void _showHospitalPopup(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hospital['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(hospital['type'], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const Text(' 1.2 km away', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            Text('Contact: ${hospital['phone']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('tel:${hospital['phone']}')),
                icon: const Icon(Icons.call),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Assistance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<PatientModel?>(
        stream: PatientController().getPatientStream(),
        builder: (context, snapshot) {
          final patient = snapshot.data;

          return Column(
            children: [
              // Map Section (70% of screen height)
              Expanded(
                flex: 7,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition?.latitude ?? 18.5204, _currentPosition?.longitude ?? 73.8567),
                      zoom: 14,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    markers: _markers,
                    style: _mapStyle, // Optional: Add custom map style for a premium look
                  ),
                ),
              ),

              // SOS & Quick Contacts Section (30% of screen height)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // SOS Button
                      GestureDetector(
                        onTap: () {
                          if (patient != null) {
                            SOSController().startSOS(patient);
                            _showSOSStatusDialog(context);
                          }
                        },
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.red, Color(0xFFD32F2F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 25,
                                spreadRadius: 5,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('*', style: TextStyle(color: Colors.white, fontSize: 32, height: 0.5)),
                                Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const Text('Quick Emergency Contacts', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickContact('Ambulance', Icons.airport_shuttle, '108'),
                          _buildQuickContact('My Hospital', Icons.local_hospital, patient?.hospitalPhone ?? ''),
                          _buildQuickContact('My Doctor', Icons.person, patient?.doctorPhone ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showSOSStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('SOS Triggered'),
          ],
        ),
        content: const Text('Help is being notified. We are contacting your doctor, family, and nearby hospitals.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Adding a simple dark-themed map style for premium feel
  static const String _mapStyle = '''
[
  {
    "featureType": "poi.medical",
    "elementType": "geometry",
    "stylers": [
      { "color": "#f5f5f5" }
    ]
  }
]
''';

  Widget _buildQuickContact(String label, IconData icon, String phone) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () {
            if (phone.isNotEmpty) launchUrl(Uri.parse('tel:$phone'));
          },
          icon: Icon(icon, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF48FB1).withOpacity(0.1),
            foregroundColor: const Color(0xFFF48FB1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/sos_controller.dart';
import '../../controllers/patient_controller.dart';
import '../../models/patient_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/settings_controller.dart';

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
      // Use the robust permission handler from SOSController
      _currentPosition = await SOSController().determinePosition();
      setState(() {});
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15.5, // Tighter zoom for local view
            ),
          ),
        );
        // Reload markers to filter by current position
        _loadHospitalMarkers();
      }
    } catch (e) {
      debugPrint("Location error: $e");
      // Fallback to default viewport if permissions denied
    }
  }

  void _loadHospitalMarkers() {
    _markers.clear();
    if (_currentPosition == null) return; // Wait for location before showing markers

    final sos = SOSController();
    final hospitals = sos.localHospitals;
    List<Map<String, dynamic>> matches = [];
    
    // 1. Check hardcoded mock hospitals
    for (var hospital in hospitals) {
      double distance = sos.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        hospital['lat'],
        hospital['lng'],
      );

      if (distance <= 2.0) {
        matches.add({...hospital, 'distance': distance});
      }
    }

    // 2. If nothing is within 2km (e.g. user is far from Pune Pune), generate local ones for demo
    if (matches.isEmpty) {
      final synthetic = sos.generateNearbyHospitals(
        _currentPosition!.latitude, 
        _currentPosition!.longitude
      );
      for (var hospital in synthetic) {
        double distance = sos.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          hospital['lat'],
          hospital['lng'],
        );
        matches.add({...hospital, 'distance': distance});
      }
    }

    // 3. Add markers for all matched/generated hospitals
    for (var hospital in matches) {
      _markers.add(
        Marker(
          markerId: MarkerId(hospital['name']),
          position: LatLng(hospital['lat'], hospital['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _showHospitalPopup(hospital, hospital['distance']),
        ),
      );
    }
    setState(() {});
  }

  void _showHospitalPopup(Map<String, dynamic> hospital, double distance) {
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
                Text(' ${distance.toStringAsFixed(1)}${SettingsController().tr(' km away')}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            Text('${SettingsController().tr('Contact')}: ${hospital['phone']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('tel:${hospital['phone']}')),
                icon: const Icon(Icons.call),
                label: Text(SettingsController().tr('Call Now')),
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
        title: Text(SettingsController().tr('Emergency Assistance'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                          _buildQuickContact(SettingsController().tr('Ambulance'), Icons.airport_shuttle, '108'),
                          _buildQuickContact(SettingsController().tr('My Hospital'), Icons.local_hospital, patient?.hospitalPhone ?? ''),
                          _buildQuickContact(SettingsController().tr('My Doctor'), Icons.person, patient?.doctorPhone ?? ''),
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
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 10),
            Text(SettingsController().tr('SOS Triggered')),
          ],
        ),
        content: Text(SettingsController().tr('Help is being notified. We are contacting your doctor, family, and nearby hospitals.')),
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

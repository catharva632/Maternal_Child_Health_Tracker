class DoctorModel {
  final String name;
  final String clinicName;
  final String phone;
  final String address;
  final String? specialization;
  final String? imagePath;
  final String? distance;
  final double? rating;

  DoctorModel({
    required this.name,
    required this.clinicName,
    required this.phone,
    required this.address,
    this.specialization,
    this.imagePath,
    this.distance,
    this.rating,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      name: map['name'] ?? '',
      clinicName: map['clinicName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      specialization: map['specialization'] ?? 'Medical Professional',
      imagePath: map['imagePath'],
      distance: map['distance'],
      rating: map['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'clinicName': clinicName,
      'phone': phone,
      'address': address,
      'specialization': specialization,
      'imagePath': imagePath,
      'distance': distance,
      'rating': rating,
      'role': 'doctor',
    };
  }
}

class DoctorModel {
  final String name;
  final String clinicName;
  final String phone;
  final String address;
  final String? specialization;
  final String? imagePath;

  DoctorModel({
    required this.name,
    required this.clinicName,
    required this.phone,
    required this.address,
    this.specialization,
    this.imagePath,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      name: map['name'] ?? '',
      clinicName: map['clinicName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      specialization: map['specialization'] ?? 'Medical Professional',
      imagePath: map['imagePath'],
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
      'role': 'doctor',
    };
  }
}

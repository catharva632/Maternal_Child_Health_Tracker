class DoctorModel {
  final String name;
  final String clinicName;
  final String phone;
  final String address;
  final double rating;
  final String distance;
  final String? imagePath;

  DoctorModel({
    required this.name,
    required this.clinicName,
    required this.phone,
    required this.address,
    required this.rating,
    required this.distance,
    this.imagePath,
  });
}

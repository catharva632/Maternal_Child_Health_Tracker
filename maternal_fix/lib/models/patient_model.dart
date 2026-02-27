class PatientModel {
  String name;
  String email;
  String phone;
  String address;
  String city;
  String pincode;
  String state;
  int pregnancyWeek;
  double weight;
  double height;
  List<String> medicalConditions;
  String? doctorName;
  String? doctorPhone;
  String? hospitalName;
  String? hospitalPhone;
  String? hospitalAddress;
  String? photoUrl;
  String? diet; // Vegetarian or Non-Veg
  bool? isWorkingProfessional;
  bool? isHighRisk;
  bool? isFirstBaby;
  List<String> badges;

  PatientModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    this.pregnancyWeek = 0,
    this.weight = 0.0,
    this.height = 0.0,
    this.medicalConditions = const [],
    this.doctorName,
    this.doctorPhone,
    this.hospitalName,
    this.hospitalPhone,
    this.hospitalAddress,
    this.photoUrl,
    this.diet,
    this.isWorkingProfessional,
    this.isHighRisk,
    this.isFirstBaby,
    this.badges = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'pincode': pincode,
      'state': state,
      'pregnancyWeek': pregnancyWeek,
      'weight': weight,
      'height': height,
      'medicalConditions': medicalConditions,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'hospitalName': hospitalName,
      'hospitalPhone': hospitalPhone,
      'hospitalAddress': hospitalAddress,
      'photoUrl': photoUrl,
      'diet': diet,
      'isWorkingProfessional': isWorkingProfessional,
      'isHighRisk': isHighRisk,
      'isFirstBaby': isFirstBaby,
      'badges': badges,
      'role': 'patient',
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '',
      state: map['state'] ?? '',
      pregnancyWeek: map['pregnancyWeek'] ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      doctorName: map['doctorName'],
      doctorPhone: map['doctorPhone'],
      hospitalName: map['hospitalName'],
      hospitalPhone: map['hospitalPhone'],
      hospitalAddress: map['hospitalAddress'],
      photoUrl: map['photoUrl'],
      diet: map['diet'],
      isWorkingProfessional: map['isWorkingProfessional'],
      isHighRisk: map['isHighRisk'],
      isFirstBaby: map['isFirstBaby'],
      badges: List<String>.from(map['badges'] ?? []),
    );
  }
}

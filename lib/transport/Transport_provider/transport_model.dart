class TransportProvider {
  final int? id;
  final String name;
  final String? contactNumber;
  final String state;
  final String stateCode;
  final String district;
  final String districtCode;
  final String taluka;
  final String talukaCode;
  final String village;
  final String villageCode;
  final int maxDistance;
  final String? vehicleType;
  final int? capacity;
  final bool isActive;
  final String? notes;
  final String? baseLocation;
  final String? vehicleNumber;
  final String? dlNumber;
  final DateTime? driverDob;
  final String? aadharNumber;
  final String? panNumber;
  final String? voterId;

  // S3 Keys matching your Django model exactly
  final String? profilePhoto;
  final String? aadharCard;
  final String? panCard;
  final String? voterIdCard;
  final String? drivingLicense;
  final String? rcBook;

  TransportProvider({
    this.id,
    required this.name,
    this.contactNumber,
    required this.state,
    required this.stateCode,
    required this.district,
    required this.districtCode,
    required this.taluka,
    required this.talukaCode,
    required this.village,
    required this.villageCode,
    required this.maxDistance,
    this.vehicleType,
    this.capacity,
    required this.isActive,
    this.notes,
    this.baseLocation,
    this.vehicleNumber,
    this.dlNumber,
    this.driverDob,
    this.aadharNumber,
    this.panNumber,
    this.voterId,
    this.profilePhoto,
    this.aadharCard,
    this.panCard,
    this.voterIdCard,
    this.drivingLicense,
    this.rcBook,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact_number': contactNumber,
      'state': state,
      'state_code': stateCode,
      'district': district,
      'district_code': districtCode,
      'taluka': taluka,
      'taluka_code': talukaCode,
      'village': village,
      'village_code': villageCode,
      'max_distance': maxDistance,
      'is_active': isActive,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'notes': notes,
      'base_location': baseLocation,
      'vehicle_number': vehicleNumber,
      'dl_number': dlNumber,
      'driver_dob': driverDob?.toIso8601String().split('T')[0],
      'aadhar_number': aadharNumber,
      'pan_number': panNumber,
      'voter_id': voterId,
      // Field names updated to match your backend exactly
      'profile_photo': profilePhoto,
      'aadhar_card': aadharCard,
      'pan_card': panCard,
      'voter_id_card': voterIdCard,
      'driving_license': drivingLicense,
      'rc_book': rcBook,
    };
  }

  factory TransportProvider.fromJson(Map<String, dynamic> json) {
    return TransportProvider(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      state: json['state'] ?? '',
      stateCode: json['state_code'] ?? '',
      district: json['district'],
      districtCode: json['district_code'],
      taluka: json['taluka'],
      talukaCode: json['taluka_code'],
      village: json['village'],
      villageCode: json['village_code'],
      baseLocation: json['base_location'],
      maxDistance: json['max_distance'],
      vehicleType: json['vehicle_type'],
      capacity: json['capacity'] is String ? int.tryParse(json['capacity']) : json['capacity'],
      isActive: json['is_active'],
      notes: json['notes'],
      vehicleNumber: json['vehicle_number'],
      dlNumber: json['dl_number'],
      driverDob: json['driver_dob'] != null ? DateTime.parse(json['driver_dob']) : null,
      aadharNumber: json['aadhar_number'],
      panNumber: json['pan_number'],
      voterId: json['voter_id'],
      profilePhoto: json['profile_photo'],
      aadharCard: json['aadhar_card'],
      panCard: json['pan_card'],
      voterIdCard: json['voter_id_card'],
      drivingLicense: json['driving_license'],
      rcBook: json['rc_book'],
    );
  }
}

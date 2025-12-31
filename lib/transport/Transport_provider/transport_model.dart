class TransportProvider {
  final int? id;
  final String name;
  final String? contactNumber;
  final String district;
  final String districtCode;
  final String taluka;
  final String talukaCode;
  final String village;
  final String villageCode;
  final int maxDistance;
  final String vehicleType;
  final bool isActive;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransportProvider({
    this.id,
    required this.name,
    required this.contactNumber,
    required this.district,
    required this.districtCode,
    required this.taluka,
    required this.talukaCode,
    required this.village,
    required this.villageCode,
    required this.maxDistance,
    required this.vehicleType,
    required this.isActive,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact_number': contactNumber,
      'district': district,
      'district_code': districtCode,
      'taluka': taluka,
      'taluka_code': talukaCode,
      'village': village,
      'village_code': villageCode,
      'max_distance': maxDistance,
      'is_active': isActive,
      'vehicle_type': vehicleType,
      'notes': notes,
    };
  }

  factory TransportProvider.fromJson(Map<String, dynamic> json) {
    return TransportProvider(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      district: json['district'],
      districtCode: json['district_code'],
      taluka: json['taluka'],
      talukaCode: json['taluka_code'],
      village: json['village'],
      villageCode: json['village_code'],
      maxDistance: json['max_distance'],
      vehicleType: json['vehicle_type'],
      isActive: json['is_active'],
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}



class TransportProvider {
  final int? id;
  final String name;
  final String? contactNumber;
  final String baseLocation;
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
    required this.baseLocation,
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
      'base_location': baseLocation,
      'max_distance': maxDistance,
      'vehicle_type': vehicleType,
      'is_active': isActive,
      'notes': notes,
    };
  }

  factory TransportProvider.fromJson(Map<String, dynamic> json) {
    return TransportProvider(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      baseLocation: json['base_location'],
      maxDistance: json['max_distance'],
      vehicleType: json['vehicle_type'],
      isActive: json['is_active'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
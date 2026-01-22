class PendingVerificationResponse {
  final int totalEntities;
  final List<VerificationEntity> entities;

  PendingVerificationResponse({
    required this.totalEntities,
    required this.entities,
  });

  factory PendingVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PendingVerificationResponse(
      totalEntities: json['total_entities'] ?? 0,
      entities: (json['entities'] as List)
          .map((e) => VerificationEntity.fromJson(e))
          .toList(),
    );
  }
}

class VerificationEntity {
  final String entityType;
  final EntityDetails entity;
  final List<VerificationStatus> verifications;

  VerificationEntity({
    required this.entityType,
    required this.entity,
    required this.verifications,
  });

  factory VerificationEntity.fromJson(Map<String, dynamic> json) {
    return VerificationEntity(
      entityType: json['entity_type'],
      entity: EntityDetails.fromJson(json['entity']),
      verifications: (json['verifications'] as List)
          .map((v) => VerificationStatus.fromJson(v))
          .toList(),
    );
  }
}

class EntityDetails {
  final int id;
  final String name;
  final String contactNumber;
  final String baseLocation;
  final String? vehicleType;

  EntityDetails({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.baseLocation,
    this.vehicleType,
  });

  factory EntityDetails.fromJson(Map<String, dynamic> json) {
    return EntityDetails(
      id: json['id'],
      name: json['name'],
      contactNumber: json['contact_number'],
      baseLocation: json['base_location'],
      vehicleType: json['vehicle_type'],
    );
  }
}

class VerificationStatus {
  final String typeDisplay;
  final String status;

  VerificationStatus({
    required this.typeDisplay,
    required this.status,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      typeDisplay: json['type_display'],
      status: json['status'],
    );
  }
}

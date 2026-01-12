class VisitPlan {
  final int id;
  final int? userId;
  final UserDetails? userDetails;
  final List<LocationInfo> states;
  final List<LocationInfo> districts;
  final List<LocationInfo> talukas;
  final List<VillageInfo> villages;
  final String? centralTeamPhone; // Added this field
  final String? state;
  final String? stateCode;
  final String? district;
  final String? districtCode;
  final String? taluka;
  final String? talukaCode;
  final String? village;
  final String? villageCode;
  final String plannedDate;
  final List<dynamic> officialsToMeet;
  final String purpose;
  final int expectedRegistrations;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String locationSummary;
  bool isSelected;
  bool isExecuted;

  VisitPlan({
    required this.id,
    this.userId,
    this.userDetails,
    required this.states,
    required this.districts,
    required this.talukas,
    required this.villages,
    this.centralTeamPhone, // Added to constructor
    this.state,
    this.stateCode,
    this.district,
    this.districtCode,
    this.taluka,
    this.talukaCode,
    this.village,
    this.villageCode,
    required this.plannedDate,
    required this.officialsToMeet,
    required this.purpose,
    required this.expectedRegistrations,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.locationSummary,
    this.isSelected = false,
    this.isExecuted = false,
  });

  factory VisitPlan.fromJson(Map<String, dynamic> json) {
    return VisitPlan(
      id: json['id'],
      userId: json['user'],
      userDetails: json['user_details'] != null ? UserDetails.fromJson(json['user_details']) : null,
      states: (json['states'] as List?)?.map((e) => LocationInfo.fromJson(e)).toList() ?? [],
      districts: (json['districts'] as List?)?.map((e) => LocationInfo.fromJson(e)).toList() ?? [],
      talukas: (json['talukas'] as List?)?.map((e) => LocationInfo.fromJson(e)).toList() ?? [],
      villages: (json['villages'] as List?)?.map((e) => VillageInfo.fromJson(e)).toList() ?? [],
      centralTeamPhone: json['central_team_phone'], // Mapped from JSON
      state: json['state'],
      stateCode: json['state_code'],
      district: json['district'],
      districtCode: json['district_code']?.toString(),
      taluka: json['taluka'],
      talukaCode: json['taluka_code']?.toString(),
      village: json['village'],
      villageCode: json['village_code']?.toString(),
      plannedDate: json['planned_date'] ?? '',
      officialsToMeet: json['officials_to_meet'] ?? [],
      purpose: json['purpose'] ?? '',
      expectedRegistrations: json['expected_registrations'] ?? 0,
      status: json['status'] ?? '',
      isExecuted: json['is_executed'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      locationSummary: json['location_summary'] ?? '',
    );
  }
}

class UserDetails {
  final int id;
  final String username;
  final String fullName;
  final String mobileNumber;
  final String role;

  UserDetails({
    required this.id,
    required this.username,
    required this.fullName,
    required this.mobileNumber,
    required this.role,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class LocationInfo {
  final String code;
  final String name;

  LocationInfo({required this.code, required this.name});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      code: json['code']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}

class VillageInfo {
  final String code;
  final String name;
  final String? talukaCode;
  final String? districtCode;

  VillageInfo({
    required this.code,
    required this.name,
    this.talukaCode,
    this.districtCode,
  });

  factory VillageInfo.fromJson(Map<String, dynamic> json) {
    return VillageInfo(
      code: json['code']?.toString() ?? '',
      name: json['name'] ?? '',
      talukaCode: json['taluka_code']?.toString(),
      districtCode: json['district_code']?.toString(),
    );
  }
}

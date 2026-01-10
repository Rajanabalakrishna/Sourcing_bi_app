

// 1. Define the VisitPlan Model
class VisitPlan {
  final int id;
  final String district;
  final String taluka;
  final String village;
  final String purpose;
  final String locationSummary;
  bool isSelected;

  VisitPlan({
    required this.id,
    required this.district,
    required this.taluka,
    required this.village,
    required this.purpose,
    required this.locationSummary,
    this.isSelected = false,
  });

  factory VisitPlan.fromJson(Map<String, dynamic> json) {
    return VisitPlan(
      id: json['id'],
      district: json['district'] ?? 'N/A',
      taluka: json['taluka'] ?? 'N/A',
      village: json['village'] ?? 'N/A',
      purpose: json['purpose'] ?? 'No purpose provided',
      locationSummary: json['location_summary'] ?? '',
    );
  }
}
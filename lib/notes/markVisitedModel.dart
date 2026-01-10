class alreadyVisitedPaln {
  final int id;
  final String village;
  final String taluka;
  final String purpose;
  final String locationSummary;
  final String plannedDate; // Added this
  bool isSelected;

  alreadyVisitedPaln({
    required this.id,
    required this.village,
    required this.taluka,
    required this.purpose,
    required this.locationSummary,
    required this.plannedDate,
    this.isSelected = false,
  });

  factory alreadyVisitedPaln.fromJson(Map<String, dynamic> json) {
    return alreadyVisitedPaln(
      id: json['id'],
      village: json['village'] ?? 'N/A',
      taluka: json['taluka'] ?? 'N/A',
      purpose: json['purpose'] ?? 'No purpose provided',
      locationSummary: json['location_summary'] ?? '',
      plannedDate: json['planned_date'] ?? 'N/A', // Mapping from API
    );
  }
}

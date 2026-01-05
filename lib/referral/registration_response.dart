class RegistrationResponse {
  final Map<String, dynamic> summary;
  final List<Mukkadam> mukkadams;

  RegistrationResponse({required this.summary, required this.mukkadams});

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      summary: json['summary'] ?? {},
      mukkadams: (json['mukkadams'] as List?)
          ?.map((i) => Mukkadam.fromJson(i))
          .toList() ?? [],
    );
  }
}

class Mukkadam {
  final int id;
  final String name;
  final String mobile;
  final String village;
  final String crewSize;
  final String registeredAt;

  Mukkadam({
    required this.id,
    required this.name,
    required this.mobile,
    required this.village,
    required this.crewSize,
    required this.registeredAt,
  });

  factory Mukkadam.fromJson(Map<String, dynamic> json) {
    return Mukkadam(
      id: json['id'],
      name: json['mukkadam_name'] ?? 'N/A',
      mobile: json['mobile_numbers'] ?? 'N/A',
      village: json['village'] ?? 'N/A',
      crewSize: json['crew_size'] ?? '0',
      registeredAt: json['registered_at'] ?? '',
    );
  }
}

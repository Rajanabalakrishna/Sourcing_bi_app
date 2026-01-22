class MukkadamDataModel {
  final int id;
  final String mukkadamName;
  final String village;
  final String crewSize;
  final String mobileNumbers;
  final String createdAt;
  final bool isPending; // true = yellow (pending), false = red (not verified)

  MukkadamDataModel({
    required this.id,
    required this.mukkadamName,
    required this.village,
    required this.crewSize,
    required this.mobileNumbers,
    required this.createdAt,
    required this.isPending,
  });

  factory MukkadamDataModel.fromJson(Map<String, dynamic> json) {
    // Mapping from the nested 'entity' object in the API response
    final entity = json['entity'] ?? {};

    // Check verifications list for verification_id
    final List<dynamic> verifications = json['verifications'] ?? [];

    // Logic: If at least one verification_id is not null, it is pending (yellow).
    // If all verification_ids are null, it is not verified (red).
    bool hasAtLeastOneVerificationId = verifications.any((v) => v['verification_id'] != null);

    return MukkadamDataModel(
      id: entity['id'] ?? 0,
      mukkadamName: entity['name'] ?? '',
      village: entity['village'] ?? '',
      crewSize: entity['crew_size']?.toString() ?? '',
      mobileNumbers: entity['mobile'] ?? '',
      createdAt: entity['created_at'] ?? '',
      isPending: hasAtLeastOneVerificationId,
    );
  }
}

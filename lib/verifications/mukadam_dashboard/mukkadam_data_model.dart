class MukkadamDataModel {
  final int id;
  final String mukkadamName;
  final String village;
  final String crewSize;
  final String mobileNumbers;
  final String createdAt;
  final bool isAadharVerified;
  final bool isPanVerified;
  final bool isVoterIdVerified;
  final bool isFaceVerified;

  MukkadamDataModel({
    required this.id,
    required this.mukkadamName,
    required this.village,
    required this.crewSize,
    required this.mobileNumbers,
    required this.createdAt,
    required this.isAadharVerified,
    required this.isPanVerified,
    required this.isVoterIdVerified,
    required this.isFaceVerified,
  });

  factory MukkadamDataModel.fromJson(Map<String, dynamic> json) {
    final entity = json['entity'] ?? {};
    final List<dynamic> verifications = json['verifications'] ?? [];

    bool aadharVerified = verifications.any((v) => v['is_aadhaar_verified'] == true);
    bool panVerified = verifications.any((v) => v['is_pan_verified'] == true);
    bool voterVerified = verifications.any((v) => v['is_voter_id_verified'] == true);
    bool faceVerified = verifications.any((v) =>
    v['is_face_match_verified'] == true && v['is_face_liveness_verified'] == true
    );

    return MukkadamDataModel(
      id: entity['id'] ?? 0,
      mukkadamName: entity['name'] ?? '',
      village: entity['village'] ?? '',
      crewSize: entity['crew_size']?.toString() ?? '',
      mobileNumbers: entity['mobile'] ?? '',
      createdAt: entity['created_at'] ?? '',
      isAadharVerified: aadharVerified,
      isPanVerified: panVerified,
      isVoterIdVerified: voterVerified,
      isFaceVerified: faceVerified,
    );
  }
}

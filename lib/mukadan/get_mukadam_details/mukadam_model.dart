
class Mukadam {
  final int id;
  final String mukkadamName;
  final String mobileNumbers;
  final String village;

  Mukadam({
    required this.id,
    required this.mukkadamName,
    required this.mobileNumbers,
    required this.village,
  });

  factory Mukadam.fromJson(Map<String, dynamic> json) {
    return Mukadam(
      id: json['id'],
      mukkadamName: json['mukkadam_name'],
      mobileNumbers: json['mobile_numbers'],
      village: json['village'],
    );
  }
}
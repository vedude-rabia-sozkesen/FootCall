class TeamModel {
  const TeamModel({
    required this.id,
    required this.teamName,
    required this.city,
    required this.district,
  });

  final String id;
  final String teamName;
  final String city;
  final String district;

  String get cityDistrict => '$city/$district';

  TeamModel copyWith({
    String? id,
    String? teamName,
    String? city,
    String? district,
  }) {
    return TeamModel(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      city: city ?? this.city,
      district: district ?? this.district,
    );
  }
}

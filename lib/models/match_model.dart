class MatchModel {
  const MatchModel({
    required this.id,
    required this.cityDistrict,
    required this.matchTitle,
    required this.timeRange,
    required this.location,
    required this.playingTeam,
    required this.creatorName,
    required this.assetLogoPath,
    required this.coverImageUrl,
  });

  final String id;
  final String cityDistrict;
  final String matchTitle;
  final String timeRange;
  final String location;
  final String playingTeam;
  final String creatorName;
  final String assetLogoPath;
  final String coverImageUrl;

  MatchModel copyWith({
    String? id,
    String? cityDistrict,
    String? matchTitle,
    String? timeRange,
    String? location,
    String? playingTeam,
    String? creatorName,
    String? assetLogoPath,
    String? coverImageUrl,
  }) {
    return MatchModel(
      id: id ?? this.id,
      cityDistrict: cityDistrict ?? this.cityDistrict,
      matchTitle: matchTitle ?? this.matchTitle,
      timeRange: timeRange ?? this.timeRange,
      location: location ?? this.location,
      playingTeam: playingTeam ?? this.playingTeam,
      creatorName: creatorName ?? this.creatorName,
      assetLogoPath: assetLogoPath ?? this.assetLogoPath,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}


part of apple_maps_flutter;

@immutable
class ApplePoint {
  const ApplePoint({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.featureType,
  });

  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final int featureType;

  /// copyWith
  ApplePoint copyWith({
    String? titleParam,
    String? subtitleParam,
    double? latitudeParam,
    double? longitudeParam,
    int? featureTypeParam,
  }) {
    return ApplePoint(
      title: titleParam ?? title,
      subtitle: subtitleParam ?? subtitle,
      latitude: latitudeParam ?? latitude,
      longitude: longitudeParam ?? longitude,
      featureType: featureTypeParam ?? featureType,
    );
  }

  /// clone
  ApplePoint clone() => copyWith();

  /// toJson（和 Circle._toJson 风格一致）
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String key, dynamic value) {
      if (value != null) {
        json[key] = value;
      }
    }

    addIfPresent('title', title);
    addIfPresent('subtitle', subtitle);
    addIfPresent('latitude', latitude);
    addIfPresent('longitude', longitude);
    addIfPresent('featureType', featureType);

    return json;
  }

  /// fromJson（通常很有用）
  factory ApplePoint.fromJson(Map<dynamic, dynamic> json) {
    return ApplePoint(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      featureType: json['featureType'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ApplePoint) return false;

    return title == other.title &&
        subtitle == other.subtitle &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        featureType == other.featureType;
  }

  @override
  int get hashCode =>
      Object.hash(title, subtitle, latitude, longitude, featureType);
}

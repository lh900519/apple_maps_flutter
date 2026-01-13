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

@immutable
class ApplePoiDetail {
  const ApplePoiDetail({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.street,
    this.city,
    this.district,
    this.state,
    this.subState,
    this.postalCode,
    this.country,
    this.countryCode,
    this.category,
    this.phone,
    this.url,
    this.timeZone,
  });

  final String? id;
  final String name;
  final double latitude;
  final double longitude;

  final String? street;
  final String? city;
  final String? district;
  final String? state;
  final String? subState;
  final String? postalCode;
  final String? country;
  final String? countryCode;

  final String? category;
  final String? phone;
  final String? url;
  final String? timeZone;

  /// copyWith
  ApplePoiDetail copyWith({
    String? idParam,
    String? nameParam,
    double? latitudeParam,
    double? longitudeParam,
    String? streetParam,
    String? cityParam,
    String? districtParam,
    String? stateParam,
    String? subStateParam,
    String? postalCodeParam,
    String? countryParam,
    String? countryCodeParam,
    String? categoryParam,
    String? phoneParam,
    String? urlParam,
    String? timeZoneParam,
  }) {
    return ApplePoiDetail(
      id: idParam ?? id,
      name: nameParam ?? name,
      latitude: latitudeParam ?? latitude,
      longitude: longitudeParam ?? longitude,
      street: streetParam ?? street,
      city: cityParam ?? city,
      district: districtParam ?? district,
      state: stateParam ?? state,
      subState: subStateParam ?? subState,
      postalCode: postalCodeParam ?? postalCode,
      country: countryParam ?? country,
      countryCode: countryCodeParam ?? countryCode,
      category: categoryParam ?? category,
      phone: phoneParam ?? phone,
      url: urlParam ?? url,
      timeZone: timeZoneParam ?? timeZone,
    );
  }

  /// clone
  ApplePoiDetail clone() => copyWith();

  /// toJson（Flutter ↔︎ iOS / MethodChannel 推荐）
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String key, dynamic value) {
      if (value != null) {
        json[key] = value;
      }
    }

    addIfPresent('id', id);
    addIfPresent('name', name);
    addIfPresent('latitude', latitude);
    addIfPresent('longitude', longitude);
    addIfPresent('street', street);
    addIfPresent('city', city);
    addIfPresent('district', district);
    addIfPresent('state', state);
    addIfPresent('subState', subState);
    addIfPresent('postalCode', postalCode);
    addIfPresent('country', country);
    addIfPresent('countryCode', countryCode);
    addIfPresent('category', category);
    addIfPresent('phone', phone);
    addIfPresent('url', url);
    addIfPresent('timeZone', timeZone);

    return json;
  }

  /// fromJson
  factory ApplePoiDetail.fromJson(Map<String, dynamic> json) {
    return ApplePoiDetail(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      street: json['street'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      subState: json['subState'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      category: json['category'] as String?,
      phone: json['phone'] as String?,
      url: json['url'] as String?,
      timeZone: json['timeZone'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ApplePoiDetail) return false;

    return id == other.id &&
        name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        street == other.street &&
        city == other.city &&
        district == other.district &&
        state == other.state &&
        subState == other.subState &&
        postalCode == other.postalCode &&
        country == other.country &&
        countryCode == other.countryCode &&
        category == other.category &&
        phone == other.phone &&
        url == other.url &&
        timeZone == other.timeZone;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        latitude,
        longitude,
        street,
        city,
        district,
        state,
        subState,
        postalCode,
        country,
        countryCode,
        category,
        phone,
        url,
        timeZone,
      );
}

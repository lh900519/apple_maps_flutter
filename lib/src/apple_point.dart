part of apple_maps_flutter;

@immutable
class ApplePoint {
  const ApplePoint({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    this.featureType,
    this.pointOfInterestCategory,
    this.iconStyleImage,
    this.iconStyleBackgroundColor,
  });

  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final int? featureType;
  final String? pointOfInterestCategory;

  final Uint8List? iconStyleImage;
  final int? iconStyleBackgroundColor;

  /// copyWith
  ApplePoint copyWith({
    String? titleParam,
    String? subtitleParam,
    double? latitudeParam,
    double? longitudeParam,
    int? featureTypeParam,
    String? pointOfInterestCategoryParam,
    Uint8List? iconStyleImageParam,
    int? iconStyleBackgroundColorParam,
  }) {
    return ApplePoint(
      title: titleParam ?? title,
      subtitle: subtitleParam ?? subtitle,
      latitude: latitudeParam ?? latitude,
      longitude: longitudeParam ?? longitude,
      featureType: featureTypeParam ?? featureType,
      pointOfInterestCategory:
          pointOfInterestCategoryParam ?? pointOfInterestCategory,
      iconStyleImage: iconStyleImageParam ?? iconStyleImage,
      iconStyleBackgroundColor:
          iconStyleBackgroundColorParam ?? iconStyleBackgroundColor,
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
    addIfPresent('pointOfInterestCategory', pointOfInterestCategory);
    addIfPresent('iconStyleImage', iconStyleImage);
    addIfPresent('iconStyleBackgroundColor', iconStyleBackgroundColor);

    return json;
  }

  /// fromJson（通常很有用）
  factory ApplePoint.fromJson(Map<dynamic, dynamic> json) {
    return ApplePoint(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      featureType: json['featureType'] as int?,
      pointOfInterestCategory: json['pointOfInterestCategory'] as String?,
      iconStyleImage: json['iconStyleImage'] as Uint8List?,
      iconStyleBackgroundColor: json['iconStyleBackgroundColor'] as int?,
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
        featureType == other.featureType &&
        pointOfInterestCategory == other.pointOfInterestCategory &&
        iconStyleImage == other.iconStyleImage &&
        iconStyleBackgroundColor == other.iconStyleBackgroundColor;
  }

  @override
  int get hashCode => Object.hash(
        title,
        subtitle,
        latitude,
        longitude,
        featureType,
        pointOfInterestCategory,
        iconStyleImage,
        iconStyleBackgroundColor,
      );
}

@immutable
class ApplePoiDetail {
  const ApplePoiDetail({
    this.identifier,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.country,
    this.isoCountryCode,
    this.subThoroughfare,
    this.thoroughfare,
    this.alternateIdentifiers,
    this.areasOfInterest,
    this.pointOfInterestCategory,
    this.fullAddress,
    this.shortAddress,
    this.phoneNumber,
    this.urls,
    this.timeZone,
    this.muid,
    this.providerId,
  });

  final String? identifier;
  final String name;

  final double latitude;
  final double longitude;

  final String? locality;
  final String? subLocality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? postalCode;
  final String? country;
  final String? isoCountryCode;

  final String? subThoroughfare;
  final String? thoroughfare;

  final List<String>? alternateIdentifiers;

  final String? areasOfInterest;
  final String? pointOfInterestCategory;

  final String? fullAddress;
  final String? shortAddress;

  final String? phoneNumber;
  final List<String>? urls;
  final String? timeZone;

  final String? muid;
  final String? providerId;

  /// copyWith
  ApplePoiDetail copyWith({
    String? identifierParam,
    String? nameParam,
    double? latitudeParam,
    double? longitudeParam,
    String? localityParam,
    String? subLocalityParam,
    String? administrativeAreaParam,
    String? subAdministrativeAreaParam,
    String? postalCodeParam,
    String? countryParam,
    String? isoCountryCodeParam,
    String? subThoroughfareParam,
    String? thoroughfareParam,
    List<String>? alternateIdentifiersParam,
    String? areasOfInterestParam,
    String? pointOfInterestCategoryParam,
    String? fullAddressParam,
    String? shortAddressParam,
    String? phoneNumberParam,
    List<String>? urlsParam,
    String? timeZoneParam,
    String? muidParam,
    String? providerIdParam,
  }) {
    return ApplePoiDetail(
      identifier: identifierParam ?? identifier,
      name: nameParam ?? name,
      latitude: latitudeParam ?? latitude,
      longitude: longitudeParam ?? longitude,
      locality: localityParam ?? locality,
      subLocality: subLocalityParam ?? subLocality,
      administrativeArea: administrativeAreaParam ?? administrativeArea,
      subAdministrativeArea:
          subAdministrativeAreaParam ?? subAdministrativeArea,
      postalCode: postalCodeParam ?? postalCode,
      country: countryParam ?? country,
      isoCountryCode: isoCountryCodeParam ?? isoCountryCode,
      subThoroughfare: subThoroughfareParam ?? subThoroughfare,
      thoroughfare: thoroughfareParam ?? thoroughfare,
      alternateIdentifiers: alternateIdentifiersParam ?? alternateIdentifiers,
      areasOfInterest: areasOfInterestParam ?? areasOfInterest,
      pointOfInterestCategory:
          pointOfInterestCategoryParam ?? pointOfInterestCategory,
      fullAddress: fullAddressParam ?? fullAddress,
      shortAddress: shortAddressParam ?? shortAddress,
      phoneNumber: phoneNumberParam ?? phoneNumber,
      urls: urlsParam ?? urls,
      timeZone: timeZoneParam ?? timeZone,
      muid: muidParam ?? muid,
      providerId: providerIdParam ?? providerId,
    );
  }

  /// clone
  ApplePoiDetail clone() => copyWith();

  /// toJson（MethodChannel / EventChannel 推荐）
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String key, dynamic value) {
      if (value != null) {
        json[key] = value;
      }
    }

    addIfPresent('identifier', identifier);
    addIfPresent('name', name);
    addIfPresent('latitude', latitude);
    addIfPresent('longitude', longitude);
    addIfPresent('locality', locality);
    addIfPresent('subLocality', subLocality);
    addIfPresent('administrativeArea', administrativeArea);
    addIfPresent('subAdministrativeArea', subAdministrativeArea);
    addIfPresent('postalCode', postalCode);
    addIfPresent('country', country);
    addIfPresent('isoCountryCode', isoCountryCode);
    addIfPresent('subThoroughfare', subThoroughfare);
    addIfPresent('thoroughfare', thoroughfare);
    addIfPresent('alternateIdentifiers', alternateIdentifiers);
    addIfPresent('areasOfInterest', areasOfInterest);
    addIfPresent('pointOfInterestCategory', pointOfInterestCategory);
    addIfPresent('fullAddress', fullAddress);
    addIfPresent('shortAddress', shortAddress);
    addIfPresent('phoneNumber', phoneNumber);
    addIfPresent('urls', urls);
    addIfPresent('timeZone', timeZone);
    addIfPresent(["d", "i", "u", "m"].reversed.join(), muid);
    addIfPresent(
      ["d", "I", "r", "e", "d", "i", "v", "o", "r", "p"].reversed.join(),
      providerId,
    );

    return json;
  }

  /// fromJson
  factory ApplePoiDetail.fromJson(Map<dynamic, dynamic> json) {
    return ApplePoiDetail(
      identifier: json['identifier'] as String?,
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locality: json['locality'] as String?,
      subLocality: json['subLocality'] as String?,
      administrativeArea: json['administrativeArea'] as String?,
      subAdministrativeArea: json['subAdministrativeArea'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      isoCountryCode: json['isoCountryCode'] as String?,
      subThoroughfare: json['subThoroughfare'] as String?,
      thoroughfare: json['thoroughfare'] as String?,
      alternateIdentifiers: (json['alternateIdentifiers'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      areasOfInterest: json['areasOfInterest'] as String?,
      pointOfInterestCategory: json['pointOfInterestCategory'] as String?,
      fullAddress: json['fullAddress'] as String?,
      shortAddress: json['shortAddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      urls: (json['urls'] as List?)?.map((e) => e.toString()).toList(),
      timeZone: json['timeZone'] as String?,
      muid: json[["d", "i", "u", "m"].reversed.join()] as String?,
      providerId: json[["d", "I", "r", "e", "d", "i", "v", "o", "r", "p"]
          .reversed
          .join()] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ApplePoiDetail) return false;

    return identifier == other.identifier &&
        name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        locality == other.locality &&
        subLocality == other.subLocality &&
        administrativeArea == other.administrativeArea &&
        subAdministrativeArea == other.subAdministrativeArea &&
        postalCode == other.postalCode &&
        country == other.country &&
        isoCountryCode == other.isoCountryCode &&
        subThoroughfare == other.subThoroughfare &&
        thoroughfare == other.thoroughfare &&
        listEquals(alternateIdentifiers, other.alternateIdentifiers) &&
        areasOfInterest == other.areasOfInterest &&
        pointOfInterestCategory == other.pointOfInterestCategory &&
        fullAddress == other.fullAddress &&
        shortAddress == other.shortAddress &&
        phoneNumber == other.phoneNumber &&
        listEquals(urls, other.urls) &&
        timeZone == other.timeZone &&
        muid == other.muid &&
        providerId == other.providerId;
  }

  @override
  int get hashCode => Object.hash(
        identifier,
        name,
        latitude,
        longitude,
        locality,
        subLocality,
        administrativeArea,
        subAdministrativeArea,
        postalCode,
        country,
        isoCountryCode,
        subThoroughfare,
        thoroughfare,
        Object.hashAll(alternateIdentifiers ?? const []),
        areasOfInterest,
        pointOfInterestCategory,
        fullAddress,
        phoneNumber,
        Object.hashAll(urls ?? const []),
        timeZone,
      );
}

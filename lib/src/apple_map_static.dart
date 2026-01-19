part of apple_maps_flutter;

class AppleMapsStatic {
  static const MethodChannel _channel =
      MethodChannel('apple_maps_plugin.luisthein.de/static_methods');

  /// reverseGeocode [ApplePoiDetail]
  static Future<ApplePoiDetail?> reverseGeocode(LatLng latLng) async {
    final detail = await _channel
        .invokeMapMethod<String, dynamic>('reverseGeocode', <String, dynamic>{
      'annotation': [latLng.latitude, latLng.longitude]
    });

    if (detail == null || !detail.containsKey('data')) return null;
    final data = detail['data'];
    if (data is! Map) return null;

    return ApplePoiDetail.fromJson(detail['data']);
  }

  /// searchRegion [ApplePoiDetail]
  static Future<List<ApplePoiDetail>?> searchRegion(
    LatLng latLng,
    String search,
    double radius,
  ) async {
    final list = await _channel
        .invokeMapMethod<String, dynamic>('searchRegion', <String, dynamic>{
      'annotation': [latLng.latitude, latLng.longitude],
      'search': search,
      'radius': radius,
    });

    if (list == null || !list.containsKey('data')) return null;
    final poiList = list['data'];
    if (poiList is! List) return null;

    return poiList.map((e) => ApplePoiDetail.fromJson(e)).toList();
  }
}

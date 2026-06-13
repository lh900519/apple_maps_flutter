// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of apple_maps_flutter;

/// Type of map tiles to display.
enum MapType {
  /// A street map where MapKit emphasizes your data over the underlying map details.
  /// MapKit 强调您的数据而不是基础地图详细信息的街道地图。
  mutedStandard,

  /// A street map that shows the position of all roads and some road names.
  /// 显示所有道路位置和一些道路名称的街道地图。
  standard,

  /// Satellite imagery of the area.
  /// 该地区的卫星图像。
  satellite,

  /// A satellite image of the area with flyover data where available.
  /// 该地区的卫星图像以及天桥数据（如果可用）。
  satelliteFlyover,

  /// A satellite image of the area with road and road name information layered on top.
  /// 该区域的卫星图像，其顶部分层了道路和道路名称信息。
  hybrid,

  /// A hybrid satellite image with flyover data where available.
  /// 带有天桥数据的混合卫星图像（如果可用）。
  hybridFlyover
}

enum TrackingMode {
  // the user's location is not followed
  none,

  // the map follows the user's location
  follow,

  // the map follows the user's location and heading
  followWithHeading,
}

/// Elevation style for iOS 16+ `MKStandardMapConfiguration`.
enum AppleMapElevationStyle { flat, realistic }

/// Emphasis style for iOS 16+ `MKStandardMapConfiguration`.
enum AppleMapEmphasisStyle { defaultStyle, muted }

/// Selectable native map feature types. Only supported on iOS 16+.
enum AppleMapSelectableFeature {
  pointsOfInterest,
  territories,
  physicalFeatures,
}

/// POI filter mode for iOS 16+ `MKStandardMapConfiguration`.
enum ApplePointOfInterestFilterMode {
  includingAll,
  excludingAll,
  including,
  excluding,
}

/// Filter for native Apple points of interest.
///
/// Category values should use MapKit raw values such as
/// `MKPOICategoryRestaurant`, matching the values returned by
/// [ApplePoint.pointOfInterestCategory].
class ApplePointOfInterestFilter {
  const ApplePointOfInterestFilter._(this.mode, [this.categories = const []]);

  const ApplePointOfInterestFilter.includingAll()
      : this._(ApplePointOfInterestFilterMode.includingAll);

  const ApplePointOfInterestFilter.excludingAll()
      : this._(ApplePointOfInterestFilterMode.excludingAll);

  const ApplePointOfInterestFilter.including(List<String> categories)
      : this._(ApplePointOfInterestFilterMode.including, categories);

  const ApplePointOfInterestFilter.excluding(List<String> categories)
      : this._(ApplePointOfInterestFilterMode.excluding, categories);

  final ApplePointOfInterestFilterMode mode;

  final List<String> categories;

  dynamic _toJson() => <String, dynamic>{
        'mode': _pointOfInterestFilterModeName(mode),
        'categories': categories,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ApplePointOfInterestFilter) return false;
    final ApplePointOfInterestFilter typedOther = other;
    return mode == typedOther.mode &&
        listEquals(categories, typedOther.categories);
  }

  @override
  int get hashCode => Object.hash(mode, Object.hashAll(categories));
}

/// iOS 16+ native Apple map feature and POI configuration.
///
/// This maps to `MKStandardMapConfiguration` and `selectableMapFeatures`.
class AppleMapFeatureConfig {
  const AppleMapFeatureConfig({
    this.elevationStyle = AppleMapElevationStyle.realistic,
    this.emphasisStyle = AppleMapEmphasisStyle.defaultStyle,
    this.pointOfInterestFilter =
        const ApplePointOfInterestFilter.includingAll(),
    this.selectableFeatures = const <AppleMapSelectableFeature>[
      AppleMapSelectableFeature.pointsOfInterest,
      AppleMapSelectableFeature.territories,
    ],
  });

  final AppleMapElevationStyle elevationStyle;

  final AppleMapEmphasisStyle emphasisStyle;

  final ApplePointOfInterestFilter? pointOfInterestFilter;

  final List<AppleMapSelectableFeature> selectableFeatures;

  dynamic _toJson() => <String, dynamic>{
        'elevationStyle': _mapElevationStyleName(elevationStyle),
        'emphasisStyle': _mapEmphasisStyleName(emphasisStyle),
        'pointOfInterestFilter': pointOfInterestFilter?._toJson(),
        'selectableFeatures':
            selectableFeatures.map(_selectableFeatureName).toList(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppleMapFeatureConfig) return false;
    final AppleMapFeatureConfig typedOther = other;
    return elevationStyle == typedOther.elevationStyle &&
        emphasisStyle == typedOther.emphasisStyle &&
        pointOfInterestFilter == typedOther.pointOfInterestFilter &&
        listEquals(selectableFeatures, typedOther.selectableFeatures);
  }

  @override
  int get hashCode => Object.hash(
        elevationStyle,
        emphasisStyle,
        pointOfInterestFilter,
        Object.hashAll(selectableFeatures),
      );
}

String _mapElevationStyleName(AppleMapElevationStyle style) {
  switch (style) {
    case AppleMapElevationStyle.flat:
      return 'flat';
    case AppleMapElevationStyle.realistic:
      return 'realistic';
  }
}

String _mapEmphasisStyleName(AppleMapEmphasisStyle style) {
  switch (style) {
    case AppleMapEmphasisStyle.defaultStyle:
      return 'defaultStyle';
    case AppleMapEmphasisStyle.muted:
      return 'muted';
  }
}

String _selectableFeatureName(AppleMapSelectableFeature feature) {
  switch (feature) {
    case AppleMapSelectableFeature.pointsOfInterest:
      return 'pointsOfInterest';
    case AppleMapSelectableFeature.territories:
      return 'territories';
    case AppleMapSelectableFeature.physicalFeatures:
      return 'physicalFeatures';
  }
}

String _pointOfInterestFilterModeName(ApplePointOfInterestFilterMode mode) {
  switch (mode) {
    case ApplePointOfInterestFilterMode.includingAll:
      return 'includingAll';
    case ApplePointOfInterestFilterMode.excludingAll:
      return 'excludingAll';
    case ApplePointOfInterestFilterMode.including:
      return 'including';
    case ApplePointOfInterestFilterMode.excluding:
      return 'excluding';
  }
}

/// Bounds for the map camera target.
// Used with [AppleMapOptions] to wrap a [LatLngBounds] value. This allows
// distinguishing between specifying an unbounded target (null `LatLngBounds`)
// from not specifying anything (null `CameraTargetBounds`).
class CameraTargetBounds {
  /// Creates a camera target bounds with the specified bounding box, or null
  /// to indicate that the camera target is not bounded.
  const CameraTargetBounds(this.bounds);

  /// The geographical bounding box for the map camera target.
  ///
  /// A null value means the camera target is unbounded.
  final LatLngBounds? bounds;

  /// Unbounded camera target.
  static const CameraTargetBounds unbounded = CameraTargetBounds(null);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final CameraTargetBounds typedOther = other;
    return bounds == typedOther.bounds;
  }

  @override
  int get hashCode => bounds.hashCode;

  @override
  String toString() {
    return 'CameraTargetBounds(bounds: $bounds)';
  }
}

class MinMaxZoomPreference {
  const MinMaxZoomPreference(this.minZoom, this.maxZoom)
      : assert(minZoom == null || maxZoom == null || minZoom <= maxZoom);

  /// The preferred minimum zoom level or null, if unbounded from below.
  final double? minZoom;

  /// The preferred maximum zoom level or null, if unbounded from above.
  final double? maxZoom;

  /// Unbounded zooming.
  static const MinMaxZoomPreference unbounded =
      MinMaxZoomPreference(null, null);

  dynamic _toJson() => <dynamic>[minZoom, maxZoom];

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final MinMaxZoomPreference typedOther = other;
    return minZoom == typedOther.minZoom && maxZoom == typedOther.maxZoom;
  }

  @override
  int get hashCode => Object.hash(minZoom, maxZoom);

  @override
  String toString() {
    return 'MinMaxZoomPreference(minZoom: $minZoom, maxZoom: $maxZoom)';
  }
}

part of apple_maps_flutter;

class SnapshotOptions {
  const SnapshotOptions({
    this.showBuildings = true,
    this.showPointsOfInterest = true,
    this.showAnnotations = true,
    this.showOverlays = true,
    this.fromView = false,
  });

  final bool showBuildings;
  final bool showPointsOfInterest;
  final bool showAnnotations;
  final bool showOverlays;

  /// iOS：直接渲染地图视图当前画面（与屏幕显示一致，包含遮罩、覆盖层与标注），
  /// 不使用 MKMapSnapshotter 重新渲染；要求地图视图已布局且在屏幕上
  final bool fromView;

  dynamic _toMap() => <String, bool>{
        'showBuildings': showBuildings,
        'showPointsOfInterest': showPointsOfInterest,
        'showAnnotations': showAnnotations,
        'showOverlays': showOverlays,
        'fromView': fromView,
      };

  @visibleForTesting
  static SnapshotOptions? fromMap(dynamic json) {
    if (json == null) {
      return null;
    }
    return SnapshotOptions(
      showBuildings: json['showBuildings'],
      showPointsOfInterest: json['showPointsOfInterest'],
      showAnnotations: json['showAnnotations'],
      showOverlays: json['showOverlays'],
      fromView: json['fromView'] ?? false,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final SnapshotOptions typedOther = other;
    return showBuildings == typedOther.showBuildings &&
        showPointsOfInterest == typedOther.showPointsOfInterest &&
        showAnnotations == typedOther.showAnnotations &&
        showOverlays == typedOther.showOverlays &&
        fromView == typedOther.fromView;
  }

  @override
  int get hashCode => Object.hash(showBuildings, showPointsOfInterest);

  @override
  String toString() =>
      'SnapshotOptions(showBuildings: $showBuildings, showPointsOfInterest: $showPointsOfInterest, showAnnotations: $showAnnotations, showOverlays: $showOverlays, fromView: $fromView)';
}

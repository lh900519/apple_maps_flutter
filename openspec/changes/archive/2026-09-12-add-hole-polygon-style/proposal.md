## Why

当前 `hole` polygon 只作为全局遮罩的 `interiorPolygons` 使用，MapKit 会将其区域扣除，但不会绘制该 polygon 自身的背景色和边框。这样 Flutter 已经传入的 `fillColor`、`strokeColor` 和 `strokeWidth` 在 hole 模式下无法体现，无法满足需要突出显示区域边界和底色的场景。

## What Changes

- 在全局遮罩之上绘制 `hole` polygon overlay。
- `hole` overlay 使用自身的 `fillColor`、`strokeColor` 和 `strokeWidth`。
- 保留全局遮罩对地图其余区域的半透明覆盖效果。
- 支持多个 hole，以及 hole 的新增、更新、删除和 `visible` 状态变化。
- 普通 polygon 的现有绘制行为保持不变。

## Capabilities

### New Capabilities

- `polygon-hole-style`: 在全局遮罩模式下绘制带独立背景色和边框样式的 hole polygon。

### Modified Capabilities

<!-- No existing capability specs are present in this repository. -->

## Impact

- `ios/Classes/Overlays/Polygons/PolygonController.swift`: manage styled hole overlays together with the global mask.
- `ios/Classes/Overlays/Polygons/FlutterPolygon.swift`: reuse the existing parsed style fields; no new platform field is required.
- Existing Flutter polygon serialization remains the source of hole style values.
- No new dependencies or public API parameters are required.

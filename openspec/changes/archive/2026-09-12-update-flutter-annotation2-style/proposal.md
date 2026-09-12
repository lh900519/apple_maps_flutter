## Why

`FlutterAnnotation2View` 当前把自定义 icon 放在标题气泡中，视觉上与新的地图标注样式不一致，也无法表达聚合地点数量。需要将它调整为毛玻璃标题气泡和锚点圆点，并通过 Flutter 公共 API 传递可选数量。

同时，毛玻璃效果需要以 iOS 13 作为最低系统能力，项目当前的 iOS 9 最低版本约束必须同步提升。

## What Changes

- **BREAKING** 将插件及示例工程的最低 iOS 版本从 9.0 提升到 13.0。
- 为 `Annotation` 增加可选的 `count` 数量属性，并通过 annotation platform-view 数据传递到 iOS。
- 将 `FlutterAnnotation2View` 调整为：
  - 移除自定义 icon 的显示；
  - 使用 `#B3FFFFFF` 白色叠加层和 iOS 13 毛玻璃效果作为标题背景；
  - 标题使用 13 号常规字重、`#FF111111` 颜色，气泡内边距为左右 8、上下 4；
  - 使用圆点作为地理坐标锚点；
  - 无 `count` 时圆点外径为 11（9 + 2），边框宽度为 2；
  - 有 `count` 时圆点高度为 20、边框宽度为 1、左右内边距为 12、最小宽度为 20，数量使用 13 号字体；
  - `count` 未设置或为 1 时显示纯圆点，`count >= 2` 时在圆点内显示数量。
- 保留标题气泡的点击、选中缩放、可见性、透明度、拖拽和 z-index 行为。
- 处理 annotation 更新时标题、数量及视图尺寸的同步刷新。
- 增加 Dart 序列化/更新测试、示例说明、iOS 手动验证项和 changelog 条目。

## Capabilities

### New Capabilities

- `annotation-display`: 定义带标题和可选数量的自定义地图 annotation 显示行为及其跨 Flutter/iOS 数据契约。

### Modified Capabilities

- 无。仓库当前没有已存在的 annotation display 主规格。

## Impact

- Flutter 公共 API：`Annotation` 构造函数、`copyWith`、相等性和 JSON 序列化。
- iOS annotation 数据模型、`FlutterAnnotation2View` 布局及 `AnnotationController` 的创建/更新路径。
- iOS Podspec 与 example 工程的 deployment target；iOS 9-12 应用将不再兼容。
- Dart 测试、example、CHANGELOG 和 iOS 手动验收。
- 不涉及 Android 实现、普通 pin/marker annotation 的既有视觉样式，或 MapKit 原生 callout 的内容协议。

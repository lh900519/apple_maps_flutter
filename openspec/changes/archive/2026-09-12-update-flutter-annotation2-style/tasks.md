## 1. Flutter Annotation Contract

- [x] 1.1 Add optional `Annotation.count` support in `lib/src/annotation.dart`, including the constructor, field, `copyWith`, equality, and JSON serialization; verify omitted counts are absent from payloads and positive counts are encoded as integers.
- [x] 1.2 Extend `test/fake_maps_controllers.dart` and `test/annotation_updates_test.dart` to deserialize and assert count omission, aggregate values, equality/change detection, and count updates; verify `flutter test test/annotation_updates_test.dart` passes.

## 2. iOS Annotation Data and Presentation

- [x] 2.1 Parse the optional `count` field in `ios/Classes/Annotations/FlutterAnnotation.swift`, include it in equality/change detection, and normalize non-positive native values as having no displayed quantity; verify the Swift source compiles with the existing annotation model.
- [ ] 2.2 Refactor `ios/Classes/Annotations/FlutterAnnotation2View.swift` into a composite frosted bubble and anchored point, removing icon/triangle rendering, applying the `#B3FFFFFF` translucent white appearance over iOS 13 material blur, using 13-point regular `#FF111111` title text with 8/4-point horizontal/vertical padding, and sizing plain points at 11 points with a 2-point border while sizing counted points at 20 points high with a 1-point border, 12-point horizontal padding, 20-point minimum width, and 13-point count text; verify no-count, count 2, count 100, long-title, reuse, and selected-state layouts in the example.
- [x] 2.3 Update `ios/Classes/Annotations/AnnotationController.swift` so creation, reuse, selection, and annotation updates configure the composite view rather than copying `MKAnnotationView.image`; verify title/count changes do not leave stale subviews and ordinary pin/marker paths remain unchanged.

## 3. iOS Baseline, Example, and Documentation

- [x] 3.1 Raise the deployment target to iOS 13.0 in `ios/apple_maps_flutter.podspec` and the example Podfile/Xcode project settings; verify all supported package and example targets report 13.0 and no active target still declares 9.0.
- [ ] 3.2 Update the example annotation screen to demonstrate a titled custom annotation without an icon and aggregate counts such as 2 and 100; verify the example shows plain and numbered points on an iOS 13-or-later simulator or device.
- [x] 3.3 Document `Annotation.count`, its display rules, and the iOS 13 minimum-version breaking change in the relevant README/API comments and `CHANGELOG.md`; verify the documented behavior matches the specification.

## 4. Validation

- [x] 4.1 Run `flutter analyze` and the complete `flutter test` suite; verify Dart API, serialization, and annotation update tests pass.
- [x] 4.2 Build the example iOS application for the iOS 13 deployment target without code signing when supported by the local Xcode environment; verify no deployment-target or Swift compilation errors remain.
- [ ] 4.3 Manually verify bubble translucency/blur, icon removal, dot anchoring, counts, large-count legibility, empty titles, view reuse, selection animation, dragging, opacity/visibility, and ordinary pin/marker behavior; record any iOS-specific limitations before completion.

> Implementation and build checks for 2.2 and 3.2 passed. The remaining visual/manual checks are pending because CoreSimulatorService repeatedly disconnects while launching or capturing the example UI in this environment.

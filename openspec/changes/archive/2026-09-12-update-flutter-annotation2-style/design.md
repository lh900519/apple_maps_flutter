## Context

The current annotation data flow serializes `Annotation` objects from Dart into a platform-view method channel. Swift reconstructs them as `FlutterAnnotation` objects, and `AnnotationController` selects a native annotation view based on the icon type and title. The titled custom path currently builds `FlutterAnnotation2View` with an image view, a white title container, and a triangular pointer. The existing update path also only copies the generated view image, so title-specific native subviews can become stale after an annotation update.

The proposal raises the iOS baseline from 9.0 to 13.0, making `UIVisualEffectView` with an iOS 13 material blur available as a supported implementation choice.

## Goals / Non-Goals

**Goals:**

- Add an explicit, backward-compatible-in-API `Annotation.count` value for aggregate locations.
- Carry title and count through the existing Dart-to-Swift annotation contract.
- Render the titled custom annotation as a frosted title bubble plus an anchored point, with optional numeric content in the point.
- Keep reuse, selection, interaction, z-order, and live annotation updates synchronized.
- Make all package and example deployment settings consistently target iOS 13.0.

**Non-Goals:**

- Do not add an annotation clustering engine or calculate counts from nearby annotations.
- Do not parse a number from localized title text such as `2 个地点`.
- Do not change ordinary pin, marker, or native MapKit callout presentation.
- Do not add a new color, typography, or bubble-style configuration API in this change.
- Do not add Android behavior; the package has no Android implementation.

## Decisions

### 1. Keep count as annotation metadata

Add `int? count` to `Annotation`, defaulting to `null`. Update its constructor, `copyWith`, equality, and JSON serialization. The wire key is `count`, and the value is sent as an integer through the existing annotation update payload. Swift reads the optional value into `FlutterAnnotation` and includes it in equality so changes trigger a native refresh.

`count` belongs to `Annotation` rather than `InfoWindow` because it describes the map point itself, not the content of a tap callout. Parsing the title or reusing `snippet` would couple the behavior to language and presentation text and would prevent independent title/count updates.

At the native boundary, missing, zero, and negative values are normalized to “no numeric quantity.” This protects the map from malformed channel data while keeping the public API simple.

### 2. Use a single native composite view for the bubble and point

Refactor `FlutterAnnotation2View` around a display container whose coordinate center is the circular point. The title bubble is laid out above it; the legacy image view and triangular pointer are removed. A `UIVisualEffectView` using an iOS 13 material blur is combined with a `#B3FFFFFF` white translucent content background, rounded corners, and the existing title sizing/truncation behavior. The point uses a warm solid fill, a white outline, and a count label only when the normalized count is at least 2.

The display container, rather than only the bubble, owns insertion animation and selected-state scaling so the complete visual remains coherent around the map coordinate. The view's measured bounds and center offset must include both bubble and point; this avoids clipping the point or shifting the geographic anchor when title/count dimensions change.

The title label uses a 13-point regular font in `#FF111111`. The bubble content inset is 8 points horizontally and 4 points vertically. A plain point uses an 11-point outer diameter (9-point point size plus a 2-point border) with a 2-point white border. A counted point uses a 20-point height, a 1-point border, 12-point horizontal padding, a 20-point minimum width, and a 13-point count font; its width grows as needed for the complete count.

### 3. Keep the current selection rule and refresh the actual view

The controller continues to use the titled custom annotation path for this presentation, so existing users who opt into that path do not have their ordinary pin/marker behavior changed. `configure(with:)` becomes the single refresh entry point for title, count, layout constraints, alpha/visibility-related presentation state, and reuse reset.

When an existing annotation changes, `AnnotationController.updateAnnotation` updates the model and calls the typed custom view configuration when the visible view is a `FlutterAnnotation2View`; it must not rely on `MKAnnotationView.image`, because the new presentation is composed of UIKit subviews rather than a single bitmap. If a changed annotation crosses between the existing icon/title presentation paths, the controller keeps the existing view-selection behavior and reconfigures or replaces the view as appropriate.

### 4. Raise every supported iOS target together

Set the plugin podspec deployment target to 13.0 and update the example Podfile/Xcode target settings that currently declare 9.0. Documentation and changelog text should state the compatibility break. No runtime fallback for pre-iOS-13 blur is required because those systems are outside the new support contract.

### 5. Validate the contract at both layers

Add Dart tests for count serialization, equality/change detection, omission, and updates. Extend the fake platform annotation deserializer so test updates preserve `count`. For iOS, manually verify the example on an iOS 13-or-later simulator/device: no-count points, counts 2 and 100, multi-digit sizing, long/empty titles, reuse, title/count updates, selection, dragging, and ordinary pin/marker annotations.

## Risks / Trade-offs

- [Risk] Raising the deployment target prevents existing iOS 9-12 applications from integrating the plugin. → Mitigation: mark it as a breaking compatibility change in the proposal, podspec, documentation, and changelog.
- [Risk] A translucent blur can look different across light/dark map content and iOS point sizes. → Mitigation: combine the material effect with the specified white alpha layer and verify against map backgrounds in manual testing.
- [Risk] A large count can make the point overlap nearby labels. → Mitigation: measure the count label and apply minimum padding/dynamic diameter while keeping the point centered on the coordinate.
- [Risk] Reused annotation views can retain old title/count state. → Mitigation: reset all labels, constraints, transforms, and visibility in `prepareForReuse`, then configure every dequeued view from the current `FlutterAnnotation`.
- [Risk] Native channel data may contain an invalid count. → Mitigation: normalize non-positive values to no numeric quantity instead of force-unwrapping or rendering malformed text.

## Migration Plan

1. Update the public model and platform payload, then update the Swift model and native view.
2. Raise podspec and example deployment targets to iOS 13.0.
3. Add tests, example coverage, documentation, and changelog notes.
4. Run Dart analysis/tests and build the example for iOS 13 or later.

Rollback consists of reverting the change before release. After a release, consumers that require iOS 9-12 must remain on the previous plugin version; there is no compatible runtime fallback in this version.

## Context

See `proposal.md` for the motivation and externally visible scope. The current iOS implementation stores hole polygons in `highlightPolygonMap` and passes them as `interiorPolygons` of one world-sized `MKPolygon`. `polygonRenderer` can style that outer mask, but MapKit does not provide separate fill and stroke styles for the mask's interior polygons.

The existing Flutter-to-iOS serialization already includes `fillColor`, `strokeColor`, `strokeWidth`, `visible`, and `points`, and `FlutterPolygon` already parses those values. The design therefore keeps the public API and data model unchanged.

## Goals / Non-Goals

**Goals:**

- Preserve one global mask for all active holes.
- Render each active hole as a separately styled overlay above the mask.
- Keep mask and styled-hole geometry synchronized across all polygon lifecycle operations.
- Preserve existing normal polygon behavior and style inputs.

**Non-Goals:**

- Adding new Dart polygon properties or changing polygon serialization.
- Changing the mask's white border color or `0.5` line width.
- Supporting independent styling of the global mask for each hole.
- Changing tap callback semantics or hit-testing rules.

## Decisions

### Keep the mask as a synthetic world polygon

Continue to create a world-sized polygon whose `interiorPolygons` are the currently visible holes. This is the smallest change that preserves the existing dimmed-background behavior and supports any number of holes in one renderer.

The synthetic mask SHALL use a black fill with `0.3` opacity, a white stroke with `0.7` opacity, and a line width of `0.5`. This keeps the mask legible while making the underlying map more visible.

Alternatives considered:

- Replacing the mask with separate screen or view layers would require camera-region synchronization and would diverge from the existing MapKit overlay architecture.
- Rendering only separate hole overlays would provide colors and borders but would lose the global dimming effect.

### Render each visible hole as a second overlay

The controller SHALL add each visible hole polygon as a normal `FlutterPolygon` overlay after the synthetic mask. Its existing renderer path, which uses the polygon's parsed fill color, stroke color, and width, provides the required styling. The hole overlays must be ordered above the mask so their fill and border are visible.

Before rebuilding, the controller SHALL remove the previous synthetic mask and previously added styled hole overlays, then rebuild from the current `highlightPolygonMap`. This makes rebuilds idempotent and avoids duplicate overlays after updates.

### Treat visibility as active-layer membership

Only holes with `visible == true` (or the existing default-visible fallback) SHALL be included in the mask and styled overlay layer. This keeps the platform behavior consistent with ordinary polygon visibility and ensures that hiding a hole closes its opening in the mask.

### Keep hole ownership in the existing map

`highlightPolygonMap` remains the source of truth for hole geometry and style. No additional persistent model or identifier format is needed. Overlay removal and rebuilding are based on the existing polygon IDs, with the synthetic mask ID continuing to be excluded from normal polygon operations.

## Risks / Trade-offs

- [Risk] Rebuilding removes and re-adds several overlays, which may cause a brief redraw during a batch update. -> Mitigation: retain the existing batch update entry points and rebuild once after processing the batch.
- [Risk] Hole overlays can affect hit testing because they become real map overlays. -> Mitigation: preserve each hole's existing `consumeTapEvents` value and verify tap behavior alongside the mask in iOS validation.
- [Risk] Overlay insertion order and user-provided z-index can place a styled hole below the mask. -> Mitigation: use a dedicated rebuild ordering that guarantees the synthetic mask is added before styled holes, while preserving z-index semantics for normal polygons.
- [Risk] A very large world polygon and many hole overlays may increase MapKit renderer work. -> Mitigation: keep one shared mask, rebuild only after collection changes, and validate with representative multiple-hole input.

## Migration Plan

No migration is required. Existing applications continue to use the same `Polygon` API; hole polygons gain visible styling from values they already provide. Rollback consists of reverting the iOS overlay-layer changes, leaving the serialized model compatible.

## Open Questions

None.

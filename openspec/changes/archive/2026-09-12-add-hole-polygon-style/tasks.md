## 1. Hole Overlay Management

- [x] 1.1 Add controller logic to track and remove styled hole overlays independently from the synthetic global mask, and verify a mask rebuild cannot leave duplicate hole overlays.
- [x] 1.2 Update mask reconstruction to include only visible holes as `interiorPolygons`, then add each visible hole overlay after the mask so its own style is rendered above it; verify one and multiple holes show the dimmed map outside and styled regions inside.

## 2. Polygon Lifecycle Behavior

- [x] 2.1 Update add, change, and remove paths so hole geometry and style changes rebuild both layers without stale overlays; verify changes to points, fill color, stroke color, stroke width, and visibility are reflected on the map.
- [x] 2.2 Preserve normal polygon rendering and z-index behavior while styled holes are present; verify a normal polygon remains rendered with its existing style alongside the global mask.

## 3. Verification

- [x] 3.1 Run the repository's relevant Flutter and iOS static/build checks and verify there are no compile or analysis errors introduced by the overlay changes.
- [ ] 3.2 Exercise the hole scenarios on an iOS map with zero, one, and multiple holes, including add/update/hide/show/remove flows, and verify background color, border color, border width, mask coverage, and tap behavior.

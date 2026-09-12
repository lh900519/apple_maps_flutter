# polygon-hole-style Specification

## Purpose

为遮罩模式下的 hole polygon 提供可见的背景色和边框样式，使高亮区域既能穿透全局遮罩，又能按照 Flutter polygon 的样式配置进行绘制。

## Requirements

### Requirement: Hole polygons SHALL retain the global mask behavior

When one or more visible polygons are marked as holes, the map SHALL render a global semi-transparent mask over the rest of the map and leave the visible hole geometries unobscured by that mask.

#### Scenario: One visible hole creates a masked map

- **WHEN** a polygon with `hole` set to `true` and `visible` set to `true` is added
- **THEN** the map displays the global mask outside the polygon and leaves the polygon area available for its own rendering

#### Scenario: Multiple visible holes share one mask

- **WHEN** multiple visible polygons with `hole` set to `true` are present
- **THEN** all of their geometries are represented as holes in the same global mask

### Requirement: Hole polygons SHALL render their configured style

Each visible hole polygon SHALL be rendered above the global mask using its configured `fillColor`, `strokeColor`, and `strokeWidth` values. The behavior SHALL use the existing serialized polygon fields and SHALL NOT require new public polygon parameters.

#### Scenario: A hole displays its background and border

- **WHEN** a visible hole has a fill color, stroke color, and stroke width
- **THEN** the hole area is filled with its configured fill color and its boundary is drawn with its configured stroke color and width

#### Scenario: Holes use different styles

- **WHEN** two visible holes have different style values
- **THEN** each hole is rendered with its own values and the style of one hole does not affect the other

### Requirement: Hole lifecycle changes SHALL update both mask and style layers

Adding, changing, hiding, showing, or removing hole polygons SHALL update the global mask and the visible styled hole overlays without leaving stale geometry or styling on the map.

#### Scenario: A hole style is changed

- **WHEN** an existing hole's fill color, stroke color, stroke width, or points are changed
- **THEN** the map reflects the new geometry and style and no previous styled copy remains

#### Scenario: A hole is hidden or shown

- **WHEN** a hole's `visible` value changes to `false` or back to `true`
- **THEN** the hidden hole is absent from both the mask and styled rendering, and the shown hole is present in both

#### Scenario: A hole is removed

- **WHEN** a hole polygon is removed
- **THEN** its geometry is removed from the global mask and its styled overlay is removed from the map

### Requirement: Normal polygon rendering SHALL remain compatible

Polygons with `hole` set to `false` SHALL continue to render using their existing fill color, stroke color, stroke width, visibility, and z-index behavior.

#### Scenario: A normal polygon is rendered alongside holes

- **WHEN** a normal polygon and one or more styled holes are present
- **THEN** the normal polygon retains its existing rendering behavior while the holes retain the global mask and individual styles

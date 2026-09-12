## Purpose

Defines the cross-platform contract and user-visible presentation for titled map annotations that use a translucent title bubble, an anchored point, and an optional aggregate location count.

## ADDED Requirements

### Requirement: Annotation count is optional and part of the annotation contract

The Flutter annotation API SHALL expose an optional integer `count` value. When provided, the value SHALL be serialized with the annotation update and SHALL participate in annotation copying, equality, and change detection.

#### Scenario: Annotation without a count

- **WHEN** an annotation is created without `count`
- **THEN** the annotation update omits the count value and the native presentation treats it as having no displayed quantity

#### Scenario: Annotation with an aggregate count

- **WHEN** an annotation is created with `count` equal to a positive integer
- **THEN** the same integer is delivered to the iOS annotation presentation without conversion to or extraction from the title text

#### Scenario: Count is updated

- **WHEN** an existing annotation changes its `count`
- **THEN** the platform receives the annotation as changed and refreshes the displayed quantity without requiring a different annotation identifier

#### Scenario: Non-positive count

- **WHEN** a count value is zero or negative at the native presentation boundary
- **THEN** the annotation displays a plain point without a numeric quantity and the map remains usable

### Requirement: Titled custom annotations use the new bubble and point presentation

The titled custom annotation presentation SHALL display the annotation title in a rounded translucent white bubble with a frosted-glass blur effect, without displaying the supplied custom icon. The geographic coordinate SHALL be represented by a warm-colored circular point positioned below and centered on the title bubble.

#### Scenario: Titled annotation is rendered

- **WHEN** a titled custom annotation is visible on an iOS 13 or later map
- **THEN** the user sees its title in the frosted bubble and a circular point at the annotation coordinate, with no custom icon rendered inside the bubble

#### Scenario: Annotation has no usable title

- **WHEN** an annotation has no title or an empty title
- **THEN** the existing non-bubble annotation presentation is used and no empty title bubble is created

#### Scenario: Bubble background and point styling

- **WHEN** the titled custom annotation presentation is rendered
- **THEN** the bubble applies a `#B3FFFFFF` translucent white appearance over the map blur, the title uses 13-point regular `#FF111111` text with 8-point horizontal and 4-point vertical padding, and the point has a visible white outline with a solid warm-colored fill

#### Scenario: Plain point dimensions

- **WHEN** the titled annotation has no displayed quantity
- **THEN** the point's outer diameter is 11 points (9-point point size plus a 2-point border) and its border width is 2 points

### Requirement: Point quantity is visually represented

The circular point SHALL display a numeric quantity when `count` is at least 2. When `count` is absent, 1, or invalid, the point SHALL remain a plain point without numeric text. Numeric quantities SHALL remain legible inside the point and support values with more than one digit.

#### Scenario: Single location point

- **WHEN** a titled annotation has no count or `count` equal to 1
- **THEN** the map displays a plain circular point without a number

#### Scenario: Aggregate point

- **WHEN** a titled annotation has `count` equal to 2 or greater
- **THEN** the map displays that decimal count in white text centered inside the circular point

#### Scenario: Large aggregate point

- **WHEN** an aggregate count contains multiple digits
- **THEN** the point grows or lays out responsively enough to keep the complete count visible without clipping

#### Scenario: Aggregate point dimensions

- **WHEN** the titled annotation displays a count
- **THEN** the point has a 20-point height, a 1-point border, 12-point horizontal padding, a minimum width of 20 points, and a 13-point count font

### Requirement: Existing annotation interaction behavior remains available

The new presentation SHALL preserve the existing titled custom annotation behavior for visibility, opacity, dragging, z-index ordering, tap handling, callout configuration, and selected-state animation. Ordinary pin and marker annotation presentations SHALL not be changed by this capability.

#### Scenario: Annotation is selected and deselected

- **WHEN** the user selects or deselects a titled custom annotation
- **THEN** the bubble and point update to the corresponding selected state while the annotation remains anchored to the same coordinate

#### Scenario: Annotation properties are updated

- **WHEN** title, count, visibility, opacity, position, or interaction settings change for an existing annotation
- **THEN** the native annotation and its visible presentation reflect the new values without stale title or count content

### Requirement: iOS deployment baseline is 13.0

The plugin and its example application SHALL declare iOS 13.0 as their minimum deployment target. The package SHALL no longer claim compatibility with iOS 9 through iOS 12.

#### Scenario: Plugin is integrated into an iOS 13 or later application

- **WHEN** the application builds and runs with an iOS 13 or later deployment target
- **THEN** the annotation presentation and its blur effect are available without an older-system fallback path

#### Scenario: Application targets an unsupported iOS version

- **WHEN** an application attempts to use the plugin with a deployment target below iOS 13
- **THEN** the integration is rejected by the declared platform requirements rather than silently presenting a different annotation style

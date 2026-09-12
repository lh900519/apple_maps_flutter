# Changelog

## 1.8.0

* Added optional `Annotation.count` support for titled custom annotations.
* Updated titled custom annotations to use a frosted title bubble and a point with optional quantity text.
* **Breaking:** Raised the minimum iOS deployment target to 13.0.

## 1.7.0

* Added configurable iOS 16+ Apple map feature presentation.
* Added elevation and emphasis styles, POI filters, and selectable map feature types.
* Snapshots now preserve the map's current map type.

## 1.6.2

* Added `cityName` and `citywithContext` to Apple POI detail results.

## 1.6.1

* Hardened point-selection callbacks against invalid annotations returned by iOS 26.4+.

## 1.6.0

* Added polygon hole and mask mode for highlighting regions while dimming the surrounding map.

## 1.5.1

* Prevented crashes when iOS 26.4+ returns an invalid annotation during deselection callbacks.

## 1.5.0

* Added map route planning between two coordinates.

## 1.4.5

* Fixed dark-mode rendering for the map.

## 1.4.4

* Added deselection callbacks for native Apple map points.

## 1.4.3

* Added `AppleMapsStatic` reverse-geocoding and region-search helpers.
* Added search-region priority and corrected `areasOfInterest` parsing.

## 1.4.2

* Refined titled custom annotation styling with dynamic text sizing and insertion animation.
* Added selectable Apple map point callbacks and Apple POI detail models.
* Added reverse-geocoding and region-search APIs with POI metadata such as icons, MUID, and provider ID.

## 1.4.1

* Added titled custom annotation views with custom callouts and selected-state animation.
* Added `Annotation.canShowCallout` and improved annotation title and layout handling.
* Added dark-mode support for map and snapshot rendering and expanded map type options.
* Refined the user-tracking button layout.

## 1.4.0

* Flutter 3.27.1 compatibility, replace `ui.hash*` with `Object.hash*`

## 1.3.0

* Animate marker position changes instead of removing and re-adding
* Fix Fatal error: Attempted to read an unowned reference but the object was already deallocated
* Fixed an issue where onCameraMove was not invoked by double-tapping
* Added insetsLayoutMarginsFromSafeArea

## 1.2.0

* Added a `markerAnnotationWithHue()` and `pinAnnotationWithHue()` method to allow custom marker/pin colors

## 1.1.0

* Added Annotation zIndex
* Added posibility to take snapshots of the map

## 1.0.3

* Fixes an issue where mapController.moveCamera would animate the camera transition
* To animate a camera movement, mapController.animateCamera should be used instead

## 1.0.2

* Removed Android folder to fix build failures

## 1.0.1

* Fixes memory leak
* Adds ability to take snapshots of the map
## 1.0.0

Thanks to @jonbhanson
* Adds null safety.
* Refreshes the example app.
* Updates .gitignore and removes files that should not be tracked.

## 0.1.4

* Animate to bounds was added. (Thanks to @nghiashiyi)
* Fixed an issue where the user location was only displayed in `authorizationInUse` status. (Thanks to @zgosalvez)

* minor fixes

## 0.1.3

* Thanks to @maxiundtesa the getter for the current zoomLevel was added
* iOS build failure for Flutter modules was fixed

## 0.1.2+5

* Fixed build failure
* Added anchor param to Annotation
* Added missing comparison of Overlay coordinates, which caused
  Circles, Annotations, Polylines and Ploygons to not update correctly
  on coordinate changes.

## 0.1.2+4

* Added configurable Anchor for infoWindows

## 0.1.2+3

* Fixed the offset of custom markers

## 0.1.2+2

* Fixed the onTap event for Annotation Callouts

## 0.1.2+1

* Added custom annotation icons from byte data
* Fixed scaling of icons from assets => see: https://flutter.dev/docs/development/ui/assets-and-images#declaring-resolution-aware-image-assets

## 0.1.2

* Annotation rework:
   * onTap for InfoWindow added
   * Multiline InfoWindow subtitle support
   * Overall Annotation handling refactored
   * Correct UserTracking Button added

## 0.1.1+2

* Fixed map freezing when setState is being called

## 0.1.1+1

* Fixed Polygon and Circle Tap events.

## 0.1.1

* Added markerAnnotation as selectable annotation type.

## 0.1.0

* Added ability to place circles on the map.

## 0.0.7

* Added ability to place polygons on the map.

## 0.0.6+4

* Fixed build issues

## 0.0.6+3

* Fixes issue #6, location permission is only requested if it's actually used.

## 0.0.6+2

* Converted iOS code to swift 5.

## 0.0.6+1

* Changed annotation initialisation, fixes custom annotation icons not showing up on the map.

## 0.0.6

* Added ability to add padding to the map

## 0.0.5

* Added ability to place polylines.

## 0.0.4

* Fixed error when updating Annotations on map.

## 0.0.3

* Added getter for visible map region.

## 0.0.2

* Added zoomBy functionality.
* Added setter for min and max zoom levels.

## 0.0.1

* Initial release.

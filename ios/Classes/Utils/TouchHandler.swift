//
//  TouchHandler.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.03.20.
//

import Foundation
import MapKit

class TouchHandler {
    
    static func handleMapTaps(tap: UITapGestureRecognizer, overlays: [MKOverlay], channel: FlutterMethodChannel?, in view: MKMapView) {
        let locationInView = tap.location(in: view)
        let touchPt: CGPoint = tap.location(in: view)
        // A tap on a visible annotation is not a tap on the empty map. Hit test against the
        // annotation view's frame: the anchor sits at the pin tip, so the tapped coordinate can
        // be far from the annotation's position when the pin head is tapped.
        if isTapOnVisibleAnnotation(touchPt, in: view) {
            return
        }
        let coord: CLLocationCoordinate2D = view.convert(touchPt, toCoordinateFrom: view)
        var didOverlayConsumeTapEvent: Bool = false
        for overlay: MKOverlay in overlays {
            if let flutterPolyline: FlutterPolyline = overlay as?  FlutterPolyline {
                if  flutterPolyline.isConsumingTapEvents ?? false && flutterPolyline.contains(coordinate: coord, mapView: view) {
                    channel?.invokeMethod("polyline#onTap", arguments: ["polylineId": flutterPolyline.id])
                    didOverlayConsumeTapEvent = true
                }
            } else if let flutterPolygon: FlutterPolygon = overlay as?  FlutterPolygon {
                if  flutterPolygon.isConsumingTapEvents ?? false && flutterPolygon.contains(coordinate: coord) {
                    channel?.invokeMethod("polygon#onTap", arguments: ["polygonId": flutterPolygon.id])
                    didOverlayConsumeTapEvent = true
                }
            } else if let flutterCircle: FlutterCircle = overlay as?  FlutterCircle {
                if  flutterCircle.isConsumingTapEvents ?? false && flutterCircle.contains(coordinate: coord) {
                    channel?.invokeMethod("circle#onTap", arguments: ["circleId": flutterCircle.id])
                    didOverlayConsumeTapEvent = true
                }
            }
        }
        if !didOverlayConsumeTapEvent {
            let locationOnMap = view.convert(locationInView, toCoordinateFrom: view)
            channel?.invokeMethod("map#onTap", arguments: ["position": [locationOnMap.latitude, locationOnMap.longitude]])
        }
    }

    private static func isTapOnVisibleAnnotation(_ point: CGPoint, in view: MKMapView) -> Bool {
        for annotation in view.annotations {
            guard let flutterAnnotation = annotation as? FlutterAnnotation,
                  flutterAnnotation.isVisible ?? true,
                  let annotationView = view.view(for: flutterAnnotation),
                  !annotationView.isHidden,
                  annotationView.alpha > 0 else { continue }
            if annotationView.convert(annotationView.bounds, to: view).contains(point) {
                return true
            }
        }
        return false
    }
}

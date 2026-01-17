//
//  AnnotationController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 09.09.19.
//

import Foundation
import MapKit

extension AppleMapController: AnnotationDelegate {
    // iOS26 及以下都会触发
    public func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
        guard #available(iOS 26.0, *) else { return }
        // 排除用户位置
        guard !(annotation is MKUserLocation) else { return }

        // 准备发送到 Flutter 的数据
        var poiData: [String: Any] = [
            "latitude": annotation.coordinate.latitude,
            "longitude": annotation.coordinate.longitude,
        ]
        if let title = annotation.title {
            poiData["title"] = title ?? ""
        }
        if let subtitle = annotation.subtitle {
            poiData["subtitle"] = subtitle ?? ""
        }

        // iOS 16+ 获取更多 POI 信息
        if let featureAnnotation = annotation as? MKMapFeatureAnnotation {
            poiData["featureType"] = featureAnnotation.featureType.rawValue
            if let pointOfInterestCategory = featureAnnotation.pointOfInterestCategory {
                poiData["pointOfInterestCategory"] = pointOfInterestCategory.rawValue
            }

            if let iconStyle = featureAnnotation.iconStyle {
                if let imageData = iconStyle.image.pngData() {
                    poiData["iconStyleImage"] = imageData
                }
                poiData["iconStyleBackgroundColor"] = iconStyle.backgroundColor.toARGBInt()
            }
        }

        // 发送事件到 Flutter
        channel.invokeMethod("applePoint#selected", arguments: poiData)
    }

    // iOS26+ 不触发
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation: FlutterAnnotation = view.annotation as? FlutterAnnotation {
            currentlySelectedAnnotation = annotation.id
            if !annotation.selectedProgrammatically {
                if !isAnnotationInFront(zIndex: annotation.zIndex) {
                    moveToFront(annotation: annotation)
                }
                onAnnotationClick(annotation: annotation)
            } else {
                annotation.selectedProgrammatically = false
            }

            if (annotation.canShowCallout ?? true) && annotation.infoWindowConsumesTapEvents {
                let tapGestureRecognizer = InfoWindowTapGestureRecognizer(target: self, action: #selector(onCalloutTapped))
                tapGestureRecognizer.annotationId = annotation.id
                tapGestureRecognizer.annotationView = view
                view.addGestureRecognizer(tapGestureRecognizer)
            }

            // 更新视图以添加边框
            if let annotationView = view as? FlutterAnnotation2View {
                annotationView.updateSelected(with: true)
                annotationView.setNeedsLayout()
            }
        } else if let annotation: MKAnnotation = view.annotation {
            // 排除用户位置
            guard !(annotation is MKUserLocation) else { return }

            // 准备发送到 Flutter 的数据
            var poiData: [String: Any] = [
                "latitude": annotation.coordinate.latitude,
                "longitude": annotation.coordinate.longitude,
            ]
            if let title = annotation.title {
                poiData["title"] = title ?? ""
            }
            if let subtitle = annotation.subtitle {
                poiData["subtitle"] = subtitle ?? ""
            }

            // iOS 16+ 获取更多 POI 信息
            if #available(iOS 16.0, *), let featureAnnotation = annotation as? MKMapFeatureAnnotation {
                poiData["featureType"] = featureAnnotation.featureType.rawValue
                if let pointOfInterestCategory = featureAnnotation.pointOfInterestCategory {
                    poiData["pointOfInterestCategory"] = pointOfInterestCategory.rawValue
                }

                if let iconStyle = featureAnnotation.iconStyle {
                    if let imageData = iconStyle.image.pngData() {
                        poiData["iconStyleImage"] = imageData
                    }
                    poiData["iconStyleBackgroundColor"] = iconStyle.backgroundColor.toARGBInt()
                }
            }

            // 发送事件到 Flutter
            channel.invokeMethod("applePoint#selected", arguments: poiData)
        }
    }

    // 取消选中时重置 isSelected 并移除边框
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annotation: FlutterAnnotation = view.annotation as? FlutterAnnotation {
            annotation.selectedProgrammatically = false

            // 更新视图以移除边框
            if let annotationView = view as? FlutterAnnotation2View {
                annotationView.updateSelected(with: false)
                annotationView.setNeedsLayout()
            }
        } else if let annotation: MKAnnotation = view.annotation {
            // 排除用户位置
            guard !(annotation is MKUserLocation) else { return }

            let coordinate = annotation.coordinate
            var poiData: [String: Any] = [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude,
            ]

            if let title = annotation.title {
                poiData["title"] = title ?? ""
            }

            if let subtitle = annotation.subtitle {
                poiData["subtitle"] = subtitle ?? ""
            }

            // iOS 16+ 获取更多 POI 信息
            if #available(iOS 16.0, *), let featureAnnotation = annotation as? MKMapFeatureAnnotation {
                // poiData["iconStyle"] = featureAnnotation.iconStyle
                poiData["featureType"] = featureAnnotation.featureType.rawValue
            }

            // 发送事件到 Flutter
            channel.invokeMethod("applePoint#deSelected", arguments: poiData)
        }
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else if let flutterAnnotation = annotation as? FlutterAnnotation {
            return getAnnotationView(annotation: flutterAnnotation)
        }
        return nil
    }

    func getAnnotationView(annotation: FlutterAnnotation) -> MKAnnotationView {
        let identifier: String = annotation.id
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        let oldflutterAnnoation = annotationView?.annotation as? FlutterAnnotation
        if annotationView == nil || oldflutterAnnoation?.icon.iconType != annotation.icon.iconType {
            if #available(iOS 11.0, *), annotation.icon.iconType == IconType.MARKER {
                annotationView = getMarkerAnnotationView(annotation: annotation, id: identifier)
            } else if annotation.icon.iconType == .CUSTOM_FROM_ASSET || annotation.icon.iconType == .CUSTOM_FROM_BYTES {
                // annotationView = getCustomAnnotationView(annotation: annotation, id: identifier)
                if let title = annotation.title, !title.isEmpty {
                    annotationView = getCustomAnnotation2View(annotation: annotation, id: identifier)
                } else {
                    annotationView = getCustomAnnotationView(annotation: annotation, id: identifier)
                }
            } else {
                annotationView = getPinAnnotationView(annotation: annotation, id: identifier)
            }
        }
        guard annotationView != nil else {
            return FlutterAnnotationView()
        }
        annotationView!.annotation = annotation
        // If annotation is not visible set alpha to 0 and don't let the user interact with it
        if !annotation.isVisible! {
            annotationView!.canShowCallout = false
            annotationView!.alpha = CGFloat(0.0)
            annotationView!.isDraggable = false
            return annotationView! as! FlutterAnnotationView
        }
        if annotation.icon.iconType != .MARKER {
            initInfoWindow(annotation: annotation, annotationView: annotationView!)
            if annotation.icon.iconType != .PIN {
                let x = (0.5 - annotation.anchor.x) * Double(annotationView!.frame.size.width)
                let y = (0.5 - annotation.anchor.y) * Double(annotationView!.frame.size.height)
                annotationView!.centerOffset = CGPoint(x: x, y: y)
            }
        }
        annotationView!.canShowCallout = annotation.canShowCallout ?? true
        annotationView!.alpha = CGFloat(annotation.alpha ?? 1.00)
        annotationView!.isDraggable = annotation.isDraggable ?? false

        return annotationView!
    }

    func annotationsToAdd(annotations: NSArray) {
        for annotation in annotations {
            let annotationData: Dictionary<String, Any> = annotation as! Dictionary<String, Any>
            addAnnotation(annotationData: annotationData)
        }
    }

    func annotationsToChange(annotations: NSArray) {
        let oldAnnotations: [MKAnnotation] = mapView.annotations
        for annotation in annotations {
            let annotationData: Dictionary<String, Any> = annotation as! Dictionary<String, Any>
            if let annotationToChange = oldAnnotations.filter({ ($0 as? FlutterAnnotation)?.id == annotationData["annotationId"] as? String })[0] as? FlutterAnnotation {
                let newAnnotation = FlutterAnnotation(fromDictionary: annotationData, registrar: registrar)
                if annotationToChange != newAnnotation {
                    if !annotationToChange.wasDragged {
                        updateAnnotation(annotation: newAnnotation)
                    } else {
                        annotationToChange.wasDragged = false
                    }
                }
            }
        }
    }

    func annotationsIdsToRemove(annotationIds: NSArray) {
        for annotationId in annotationIds {
            if let _annotationId: String = annotationId as? String {
                removeAnnotation(id: _annotationId)
            }
        }
    }

    func removeAllAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }

    func onAnnotationClick(annotation: MKAnnotation) {
        if let flutterAnnotation: FlutterAnnotation = annotation as? FlutterAnnotation {
            flutterAnnotation.wasDragged = true
            channel.invokeMethod("annotation#onTap", arguments: ["annotationId": flutterAnnotation.id])
        }
    }

    func selectAnnotation(with id: String) {
        if let annotation: FlutterAnnotation = getAnnotation(with: id) {
            annotation.selectedProgrammatically = true
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    func hideAnnotation(with id: String) {
        if let annotation: FlutterAnnotation = getAnnotation(with: id) {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }

    func isAnnotationSelected(with id: String) -> Bool {
        return mapView.selectedAnnotations.contains(where: { annotation in self.getAnnotation(with: id) == (annotation as? FlutterAnnotation) })
    }

    private func removeAnnotation(id: String) {
        if let flutterAnnotation: FlutterAnnotation = getAnnotation(with: id) {
            mapView.removeAnnotation(flutterAnnotation)
        }
    }

    private func initInfoWindow(annotation: FlutterAnnotation, annotationView: MKAnnotationView) {
        let x = getInfoWindowXOffset(annotationView: annotationView, annotation: annotation)
        let y = getInfoWindowYOffset(annotationView: annotationView, annotation: annotation)
        annotationView.calloutOffset = CGPoint(x: x, y: y)
        if #available(iOS 9.0, *) {
            let lines = annotation.subtitle?.split(whereSeparator: { $0.isNewline })
            if lines != nil {
                let customCallout = UIStackView()
                customCallout.axis = .vertical
                customCallout.alignment = .fill
                customCallout.distribution = .fill
                for line in lines! {
                    let subtitle = UILabel()
                    subtitle.text = String(line)
                    customCallout.addArrangedSubview(subtitle)
                }
                annotationView.detailCalloutAccessoryView = customCallout
            }
        }
    }

    @objc func onCalloutTapped(infoWindowTap: InfoWindowTapGestureRecognizer) {
        if infoWindowTap.annotationId != nil && currentlySelectedAnnotation == infoWindowTap.annotationId! {
            channel.invokeMethod("infoWindow#onTap", arguments: ["annotationId": infoWindowTap.annotationId])
        }
        if infoWindowTap.annotationView != nil && currentlySelectedAnnotation != infoWindowTap.annotationId! {
            infoWindowTap.annotationView?.removeGestureRecognizer(infoWindowTap)
        }
    }

    private func getAnnotation(with id: String) -> FlutterAnnotation? {
        return mapView.annotations.filter { annotation in (annotation as? FlutterAnnotation)?.id == id }.first as? FlutterAnnotation
    }

    private func annotationExists(with id: String) -> Bool {
        return getAnnotation(with: id) != nil
    }

    private func addAnnotation(annotationData: Dictionary<String, Any>) {
        let annotation: FlutterAnnotation = FlutterAnnotation(fromDictionary: annotationData, registrar: registrar)
        addAnnotation(annotation: annotation)
    }

    /**
     Checks if an Annotation with the same id exists and removes it before adding if necessary
     - Parameter annotation: the FlutterAnnotation that should be added
     */
    private func addAnnotation(annotation: FlutterAnnotation) {
        if annotationExists(with: annotation.id) {
            removeAnnotation(id: annotation.id)
        }
        if annotation.zIndex == -1 {
            annotation.zIndex = getNextAnnotationZIndex()
            channel.invokeMethod("annotation#onZIndexChanged", arguments: ["annotationId": annotation.id!, "zIndex": annotation.zIndex])
        }
        mapView.addAnnotation(annotation)
    }

    private func updateAnnotation(annotation: FlutterAnnotation) {
        if let oldAnnotation = getAnnotation(with: annotation.id) {
            UIView.animate(withDuration: 0.32, animations: {
                oldAnnotation.coordinate = annotation.coordinate
                oldAnnotation.zIndex = annotation.zIndex
                oldAnnotation.anchor = annotation.anchor
                oldAnnotation.alpha = annotation.alpha
                oldAnnotation.isVisible = annotation.isVisible
                oldAnnotation.title = annotation.title
                oldAnnotation.subtitle = annotation.subtitle
            })

            // Update the annotation view with the new image
            if let view = mapView.view(for: oldAnnotation) {
                let newAnnotationView = getAnnotationView(annotation: annotation)
                view.image = newAnnotationView.image
            }
        }
    }

    private func getNextAnnotationZIndex() -> Double {
        let mapViewAnnotations = mapView.getMapViewAnnotations()
        if mapViewAnnotations.isEmpty {
            return 0
        }
        return (mapViewAnnotations.last??.zIndex ?? 0) + 1
    }

    private func isAnnotationInFront(zIndex: Double) -> Bool {
        return (mapView.getMapViewAnnotations().last??.zIndex ?? 0) == zIndex
    }

    private func getPinAnnotationView(annotation: FlutterAnnotation, id: String) -> MKPinAnnotationView {
        var pinAnnotationView: MKPinAnnotationView
        if #available(iOS 11.0, *) {
            self.mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: id)
            pinAnnotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: id, for: annotation) as! MKPinAnnotationView
        } else {
            pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
        }
        pinAnnotationView.layer.zPosition = annotation.zIndex

        if let hueColor: Double = annotation.icon.hueColor {
            pinAnnotationView.pinTintColor = UIColor(hue: hueColor, saturation: 1, brightness: 1, alpha: 1)
        }

        return pinAnnotationView
    }

    @available(iOS 11.0, *)
    private func getMarkerAnnotationView(annotation: FlutterAnnotation, id: String) -> FlutterMarkerAnnotationView {
        mapView.register(FlutterMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: id)
        let markerAnnotationView: FlutterMarkerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: id, for: annotation) as! FlutterMarkerAnnotationView
        markerAnnotationView.stickyZPosition = annotation.zIndex

        if let hueColor: Double = annotation.icon.hueColor {
            markerAnnotationView.markerTintColor = UIColor(hue: hueColor, saturation: 1, brightness: 1, alpha: 1)
        }

        return markerAnnotationView
    }

    private func getCustomAnnotationView(annotation: FlutterAnnotation, id: String) -> FlutterAnnotationView {
        let annotationView: FlutterAnnotationView
        if #available(iOS 11.0, *) {
            self.mapView.register(FlutterAnnotationView.self, forAnnotationViewWithReuseIdentifier: id)
            annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: id, for: annotation) as! FlutterAnnotationView
        } else {
            annotationView = FlutterAnnotationView(annotation: annotation, reuseIdentifier: id)
        }
        annotationView.image = annotation.icon.image
        annotationView.stickyZPosition = annotation.zIndex
        return annotationView
    }

    private func getCustomAnnotation2View(annotation: FlutterAnnotation, id: String) -> FlutterAnnotation2View {
        var annotationView: FlutterAnnotation2View
        mapView.register(FlutterAnnotation2View.self, forAnnotationViewWithReuseIdentifier: id)
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: id, for: annotation) as! FlutterAnnotation2View

        annotationView.configure(with: annotation)

        return annotationView
    }

    private func getInfoWindowXOffset(annotationView: MKAnnotationView, annotation: FlutterAnnotation) -> CGFloat {
        if annotation.icon.iconType == .PIN {
            return annotationView.frame.origin.x - (annotationView.frame.origin.x * CGFloat(annotation.calloutOffset.x))
        }
        return annotationView.frame.origin.x + (annotationView.frame.width * CGFloat(annotation.calloutOffset.x))
    }

    private func getInfoWindowYOffset(annotationView: MKAnnotationView, annotation: FlutterAnnotation) -> CGFloat {
        return annotationView.frame.height * CGFloat(annotation.calloutOffset.y)
    }

    private func moveToFront(annotation: FlutterAnnotation) {
        let id: String = annotation.id
        annotation.zIndex = getNextAnnotationZIndex()
        channel.invokeMethod("annotation#onZIndexChanged", arguments: ["annotationId": id, "zIndex": annotation.zIndex])
        addAnnotation(annotation: annotation)
        selectAnnotation(with: id)
    }
}

class InfoWindowTapGestureRecognizer: UITapGestureRecognizer {
    var annotationView: UIView?
    var annotationId: String?
}

extension UIColor {
    func toARGBInt() -> Int {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let ai = Int(a * 255) & 0xFF
        let ri = Int(r * 255) & 0xFF
        let gi = Int(g * 255) & 0xFF
        let bi = Int(b * 255) & 0xFF

        return (ai << 24) | (ri << 16) | (gi << 8) | bi
    }
}

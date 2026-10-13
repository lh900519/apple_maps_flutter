//
//  FlutterPolygon.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 07.03.20.
//

import Foundation
import MapKit

class FlutterPolygon: MKPolygon {
    var strokeColor: UIColor?
    var fillColor: UIColor?
    var isConsumingTapEvents: Bool?
    var width: CGFloat?
    var isVisible: Bool?
    var id: String?
    var zIndex: Int? = -1
    var coordinates: [CLLocationCoordinate2D]?
  
    /// 是否启用遮罩模式（true = 该 polygon 会在全局遮罩上挖孔显示）
    var hole: Bool = false
    
    convenience init(fromDictionaray polygonData: Dictionary<String, Any>) {
        let points = polygonData["points"] as! NSArray
        var _points: [CLLocationCoordinate2D] = []
        for point in points {
           if let _point: NSArray = point as? NSArray {
               _points.append(CLLocationCoordinate2D.init(latitude: _point[0] as! CLLocationDegrees, longitude: _point[1] as! CLLocationDegrees))
           }
        }
        self.init(coordinates: _points, count: points.count)
        self.coordinates = _points
        self.strokeColor = JsonConversions.convertColor(data: polygonData["strokeColor"] as! NSNumber)
        self.fillColor = JsonConversions.convertColor(data: polygonData["fillColor"] as! NSNumber)
        self.isConsumingTapEvents = polygonData["consumeTapEvents"] as? Bool
        self.width = polygonData["strokeWidth"] as? CGFloat
        self.id = polygonData["polygonId"] as? String
        self.isVisible = polygonData["visible"] as? Bool
        self.zIndex = polygonData["zIndex"] as? Int
      
        // 从 Flutter 传入的数据中读取
        self.hole = polygonData["hole"] as? Bool ?? false
    }
    
    static func == (lhs: FlutterPolygon, rhs: FlutterPolygon) -> Bool {
        return lhs.strokeColor == rhs.strokeColor && lhs.fillColor == rhs.fillColor && lhs.isConsumingTapEvents == rhs.isConsumingTapEvents && lhs.width ==  rhs.width && lhs.isVisible == rhs.isVisible && lhs.zIndex == rhs.zIndex && lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    static func != (lhs: FlutterPolygon, rhs: FlutterPolygon) -> Bool {
        return !(lhs == rhs)
    }
}

extension FlutterPolygon: FlutterOverlay {
    func getCAShapeLayer(snapshot: MKMapSnapshotter.Snapshot) -> CAShapeLayer {
        let path = UIBezierPath()
        let shapeLayer = CAShapeLayer()

        if !(self.isVisible ?? true) || self.pointCount == 0 {
            return shapeLayer
        }

        // 使用 MKPolygon 自身的点而不是 coordinates：遮罩多边形通过
        // init(coordinates:count:interiorPolygons:) 创建，coordinates 为 nil。
        // Thus we use snapshot.point() to save the pain.
        FlutterPolygon.appendRing(of: self, to: path, snapshot: snapshot)

        // 内环（已点亮区域）配合 even-odd 填充规则镂空，与地图上的遮罩一致
        for interior in self.interiorPolygons ?? [] {
            FlutterPolygon.appendRing(of: interior, to: path, snapshot: snapshot)
        }

        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round

        if self.interiorPolygons != nil {
            // 与 PolygonController.polygonRenderer 中遮罩的样式保持一致
            shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
            shapeLayer.strokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
            shapeLayer.lineWidth = 0.5
        } else {
            shapeLayer.lineWidth = self.width ?? 0
            shapeLayer.strokeColor = self.strokeColor?.cgColor ?? UIColor.clear.cgColor
            shapeLayer.fillColor = self.fillColor?.cgColor ?? UIColor.clear.cgColor
        }

        return shapeLayer
    }

    private static func appendRing(of polygon: MKPolygon, to path: UIBezierPath, snapshot: MKMapSnapshotter.Snapshot) {
        let count = polygon.pointCount
        guard count > 0 else { return }
        let points = polygon.points()
        path.move(to: snapshot.point(for: points[0].coordinate))
        for i in 1..<count {
            path.addLine(to: snapshot.point(for: points[i].coordinate))
        }
        path.close()
    }
}


public extension MKPolygon {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coordinate)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        if polygonRenderer.path == nil {
          return false
        } else{
            return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
}

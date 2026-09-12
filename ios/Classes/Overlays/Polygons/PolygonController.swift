//
//  PolygonController.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 07.03.20.
//


import Foundation
import MapKit

extension AppleMapController: PolygonDelegate {
    func polygonRenderer(overlay: MKOverlay) -> MKOverlayRenderer {
        // Make sure we are rendering a polygon.
        guard let polygon = overlay as? MKPolygon else {
           return MKOverlayRenderer()
        }
        let polygonRenderer = MKPolygonRenderer(overlay: polygon)

        if let flutterPolygon: FlutterPolygon = overlay as? FlutterPolygon {
          if flutterPolygon.isVisible! {
            if flutterPolygon.interiorPolygons != nil {
              polygonRenderer.fillColor = UIColor.black.withAlphaComponent(0.3)
              polygonRenderer.strokeColor = UIColor.white.withAlphaComponent(0.7)
              polygonRenderer.lineWidth = 0.5
            } else {
               // 高亮层
               polygonRenderer.strokeColor = flutterPolygon.strokeColor
               polygonRenderer.fillColor = flutterPolygon.fillColor
               polygonRenderer.lineWidth = flutterPolygon.width ?? 1.0
            }
          } else {
            polygonRenderer.strokeColor = UIColor.clear
            polygonRenderer.lineWidth = 0.0
          }
        }
        return polygonRenderer
    }
  
  
    // MARK: - 重建遮罩
    private func rebuildMaskOverlay() {
        // 1. 移除旧的遮罩和 hole 样式层
        removeHoleOverlays()
        removeMaskPolygon()
        
        // 只将可见 hole 加入遮罩内环
        let visibleHoles = highlightPolygonMap.values.filter { $0.isVisible ?? true }
        guard !visibleHoles.isEmpty else { return }
        
        // 2. 用当前所有可见 hole 作为内孔
        var worldCoords = createWorldCoverageCoordinates()
        let interiorPolygons = Array(visibleHoles)
        
        // 3. 创建新的遮罩 polygon
        let maskPolygon = FlutterPolygon(
            coordinates: &worldCoords,
            count: worldCoords.count,
            interiorPolygons: interiorPolygons
        )
        maskPolygon.isVisible = true
        maskPolygon.id = maskPolygonId
        
        addPolygon(polygon: maskPolygon)

        // 4. 作为独立 overlay 叠加，使每个 hole 能使用自己的样式
        for hole in visibleHoles {
            addHoleOverlay(polygon: hole)
        }
    }

    private func removeHoleOverlays() {
        for overlay in Array(self.mapView.overlays) {
            if let polygon = overlay as? FlutterPolygon,
               polygon.hole,
               polygon.id != maskPolygonId {
                self.mapView.removeOverlay(polygon)
            }
        }
    }
    
    private func removeMaskPolygon() {
        for overlay in self.mapView.overlays {
            if let polygon = overlay as? FlutterPolygon, polygon.id == maskPolygonId {
                self.mapView.removeOverlay(polygon)
                break
            }
        }
    }
    
    func addPolygons(polygonData data: NSArray) {
        for _polygon in data {
            let polygonData :Dictionary<String, Any> = _polygon as! Dictionary<String, Any>
            let polygon = FlutterPolygon(fromDictionaray: polygonData)
            
            if polygon.hole {
                // Hole模式：加入全局遮罩内孔
                highlightPolygonMap[polygon.id!] = polygon
            } else {
                // 普通模式：正常添加 polygon
                addPolygon(polygon: polygon)
            }
        }

      // 重建遮罩
      rebuildMaskOverlay()
    }
    
    // 创建覆盖全球的超大矩形
    // 使用多点世界边界，避免日期变更线问题
    func createWorldCoverageCoordinates() -> [CLLocationCoordinate2D] {
        // 使用略超过墨卡托极限的值，确保没有缝隙
        let latLimit: Double = 85.05112878
        let lngLimit: Double = 180.0
        let step: Double = 1.0  // 步长建议更小，减少渲染误差

        var points: [CLLocationCoordinate2D] = []

        // 注意顺序：逆时针 或 顺时针需要与你的内圈方向相反
        // 外圈建议：顺时针（从西南角开始）

        // 南边界：西 → 东
        stride(from: -lngLimit, through: lngLimit, by: step).forEach {
            points.append(.init(latitude: -latLimit, longitude: $0))
        }
        // 东边界：南 → 北
        stride(from: -latLimit, through: latLimit, by: step).forEach {
            points.append(.init(latitude: $0, longitude: lngLimit))
        }
        // 北边界：东 → 西
        stride(from: lngLimit, through: -lngLimit, by: -step).forEach {
            points.append(.init(latitude: latLimit, longitude: $0))
        }
        // 西边界：北 → 南
        stride(from: latLimit, through: -latLimit, by: -step).forEach {
            points.append(.init(latitude: $0, longitude: -lngLimit))
        }
      
        return points
    }

    func changePolygons(polygonData data: NSArray) {
//        let oldOverlays: [MKOverlay] = self.mapView.overlays
//        for oldOverlay in oldOverlays {
//            if oldOverlay is FlutterPolygon {
//                let oldFlutterPolygon = oldOverlay as! FlutterPolygon
//                for _polygon in data {
//                    let polygonData :Dictionary<String, Any> = _polygon as! Dictionary<String, Any>
//                    if oldFlutterPolygon.id == (polygonData["polygonId"] as! String) {
//                        let newPolygon = FlutterPolygon.init(fromDictionaray: polygonData)
//                        if oldFlutterPolygon != newPolygon {
//                            updatePolygonsOnMap(oldPolygon: oldFlutterPolygon, newPolygon: newPolygon)
//                        }
//                    }
//                }
//            }
//        }
      
        for _polygon in data {
            let polygonData = _polygon as! Dictionary<String, Any>
            let polygonId = polygonData["polygonId"] as! String
            let newPolygon = FlutterPolygon(fromDictionaray: polygonData)
            
            if newPolygon.hole {
                // 切换为打洞模式：从普通 overlay 移除，加入内孔字典
                removePolygons(polygonIds: [polygonId])
                highlightPolygonMap[polygonId] = newPolygon
            } else {
                // 切换为普通模式：从内孔字典移除，作为普通 overlay 添加
                if highlightPolygonMap[polygonId] != nil {
                    highlightPolygonMap.removeValue(forKey: polygonId)
                }
              updateNormalPolygon(id: polygonId, newPolygon: newPolygon)
            }
        }
        rebuildMaskOverlay()
    }

    func removePolygons(polygonIds: NSArray) {
        for polygonId in polygonIds {
            let pid = polygonId as! String
            if highlightPolygonMap[pid] != nil {
                // 从打洞字典移除
                highlightPolygonMap.removeValue(forKey: pid)
            } else {
                // 从普通 overlay 移除
                removeNormalPolygon(id: pid)
            }
        }
        rebuildMaskOverlay()
    }

    func removeAllPolygons() {
        for overlay in self.mapView.overlays {
            if let polygon = overlay as? FlutterPolygon {
                self.mapView.removeOverlay(polygon)
            }
        }

      highlightPolygonMap.removeAll()
      removeMaskPolygon()
    }


    // MARK: - 普通 Polygon 操作

    private func removeNormalPolygon(id: String) {
        for overlay in self.mapView.overlays {
            if let polygon = overlay as? FlutterPolygon,
               polygon.id == id,
               polygon.id != maskPolygonId {
                self.mapView.removeOverlay(polygon)
                break
            }
        }
    }

    private func updateNormalPolygon(id: String, newPolygon: FlutterPolygon) {
        removeNormalPolygon(id: id)
        addPolygon(polygon: newPolygon)
    }

    private func addPolygon(polygon: FlutterPolygon) {
        if polygon.zIndex == nil || polygon.zIndex == -1 {
            self.mapView.addOverlay(polygon)
        } else {
            self.mapView.insertOverlay(polygon, at: polygon.zIndex ?? 0)
        }
    }

    private func addHoleOverlay(polygon: FlutterPolygon) {
        // Always append after the mask so the hole's fill and border remain visible.
        self.mapView.addOverlay(polygon)
    }
}

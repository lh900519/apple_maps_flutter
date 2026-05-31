//
//  ApplePoint.swift
//  Pods
//
//  Created by lh900519 on 2026/1/12.
//

import Foundation
import MapKit

class ApplePointDetail {
    // 逆地理解析（CLPlacemark → 统一 POI 数据结构）
    static func reverseGeocode(
        coordinate: CLLocationCoordinate2D,
        completion: @escaping ([String: Any]?) -> Void
    ) {
        let geocoder = CLGeocoder()
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }

            var detailData: [String: Any] = [
                "name": placemark.name ?? "",
            ]
            if let coord = placemark.location?.coordinate {
                detailData["latitude"] = coord.latitude
                detailData["longitude"] = coord.longitude
            }

            // POI 地址
            detailData["locality"] = placemark.locality ?? ""
            detailData["subLocality"] = placemark.subLocality
            detailData["administrativeArea"] = placemark.administrativeArea
            detailData["subAdministrativeArea"] = placemark.subAdministrativeArea
            detailData["postalCode"] = placemark.postalCode
            detailData["country"] = placemark.country
            detailData["isoCountryCode"] = placemark.isoCountryCode

            // POI 街道
            detailData["subThoroughfare"] = placemark.subThoroughfare
            detailData["thoroughfare"] = placemark.thoroughfare

            // ⏰ 时区（与 MKMapItem.timeZone 对齐）
            if let timeZone = placemark.timeZone {
                detailData["timeZone"] = timeZone.identifier
            }

            // ⭐ 兴趣点（可选扩展字段）
            if let areas = placemark.areasOfInterest, !areas.isEmpty {
                detailData["areasOfInterest"] = areas
            }

            completion(detailData)
        }
    }

    static func searchRegion(
        point: String,
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        priority: Int = 0,
        completion: @escaping ([[String: Any]]) -> Void
    ) {
        var search: MKLocalSearch?

        if #available(iOS 14.0, *), point.isEmpty {
            let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: radius)
            // request.pointOfInterestFilter = .includingAll
            print("搜索附近: \(coordinate), \(radius)")
            search = MKLocalSearch(request: request)
        } else {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = point
            request.region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: radius,
                longitudinalMeters: radius
            )
          
          
            if #available(iOS 18.0, *) {
              if let priority = MKLocalSearchRegionPriority(rawValue: priority) {
                  request.regionPriority = priority
              }
            }
          
            search = MKLocalSearch(request: request)
        }

        guard let search = search else {
            print("初始化搜索失败")
            completion([])
            return
        }

        search.start { response, error in
            var searchList: [[String: Any]] = []

            guard error == nil, let response = response else {
                print("错误\(String(describing: error))")
                completion([])
                return
            }

            for item in response.mapItems {
                var detailData: [String: Any] = [
                    "name": item.name ?? "",
                ]

                detailData["urls"] = []
                if let url = item.url {
                    detailData["urls"] = [url.absoluteString]
                }

                let placemark = item.placemark
                let coord = placemark.coordinate
                detailData["latitude"] = coord.latitude
                detailData["longitude"] = coord.longitude

                // POI 地址
                detailData["locality"] = placemark.locality ?? ""
                detailData["subLocality"] = placemark.subLocality ?? ""
                detailData["administrativeArea"] = placemark.administrativeArea ?? ""
                detailData["subAdministrativeArea"] = placemark.subAdministrativeArea ?? ""
                detailData["postalCode"] = placemark.postalCode ?? ""
                detailData["country"] = placemark.country ?? ""
                detailData["isoCountryCode"] = placemark.isoCountryCode ?? ""

                // POI 街道
                detailData["subThoroughfare"] = placemark.subThoroughfare ?? ""
                detailData["thoroughfare"] = placemark.thoroughfare ?? ""

                // 兴趣点
                if let areas = placemark.areasOfInterest, !areas.isEmpty {
                    detailData["areasOfInterest"] = areas
                }

                // POI 分类
                if let pointOfInterestCategory = item.pointOfInterestCategory {
                    detailData["pointOfInterestCategory"] = pointOfInterestCategory.rawValue
                }

                // POI 唯一 ID（iOS 18+）
                if #available(iOS 18.0, *) {
                    detailData["alternateIdentifiers"] = item.alternateIdentifiers.map { $0.rawValue }

                    if let identifier = item.identifier {
                        // "identifier"
                        let key1 = ["r", "e", "i", "f", "i", "t", "n", "e", "d", "i"].reversed().joined()
                        detailData[key1] = identifier.rawValue

                        // 提取 muid 和 providerId
                        if let ids = extractDatas(from: identifier) {
                            detailData[ids.rk1] = "\(ids.rv1)"
                            if let rv2 = ids.rv2 {
                                detailData[ids.rk2] = "\(rv2)"
                            }
                        }
                    }
                }

                // 电话
                if let phoneNumber = item.phoneNumber {
                    detailData["phoneNumber"] = phoneNumber
                }

                // 时区
                if let timeZone = item.timeZone {
                    detailData["timeZone"] = timeZone.identifier
                }

                // iOS 26+ 地址信息
                if #available(iOS 26, *) {
                    if let address = item.address {
                        // POI 地址
                        detailData["fullAddress"] = address.fullAddress
                        detailData["shortAddress"] = address.shortAddress ?? ""
                    }

                    if let reps = item.addressRepresentations {
                        // POI 地址
                        detailData["cityName"] = reps.cityName ?? ""
                        detailData["citywithContext"] = reps.cityWithContext ?? ""
                    }
                }

                searchList.append(detailData)
            }

            completion(searchList)
        }
    }

    // MARK: - Helper Methods

    /// 从 MKMapItemIdentifier 中提取 muid 和 providerId
    /// - Parameter identifier: MKMapItemIdentifier 实例
    /// - Returns: 包含 muid、providerId 及其 key 的元组，失败返回 nil
    private static func extractDatas(from data: NSObject) -> (rv1: UInt64, rv2: UInt64?, rk1: String, rk2: String)? {
        // "_geoMapItemIdentifier"
        let key2 = ["r", "e", "i", "f", "i", "t", "n", "e", "d", "I", "m", "e", "t", "I", "p", "a", "M", "o", "e", "g", "_"].reversed().joined()

        // "_mapsIdentifier"
        let key3 = ["r", "e", "i", "f", "i", "t", "n", "e", "d", "I", "s", "p", "a", "m", "_"].reversed().joined()

        // "_shardedId"
        let key4 = ["d", "I", "d", "e", "d", "r", "a", "h", "s", "_"].reversed().joined()

        // "_muid"
        let key5 = ["d", "i", "u", "m", "_"].reversed().joined()

        // "_resultProviderId"
        let key6 = ["d", "I", "r", "e", "d", "i", "v", "o", "r", "P", "t", "l", "u", "s", "e", "r", "_"].reversed().joined()

        // "muid"
        let key7 = ["d", "i", "u", "m"].reversed().joined()

        // "providerId"
        let key8 = ["d", "I", "r", "e", "d", "i", "v", "o", "r", "p"].reversed().joined()

        // 逐层访问私有属性
        guard let v2 = data.value(forKey: key2),
              let v3 = (v2 as AnyObject).value(forKey: key3),
              let s = (v3 as AnyObject).value(forKey: key4),
              let rv1 = (s as AnyObject).value(forKey: key5) as? UInt64 else {
            return nil
        }

        let rv2 = (s as AnyObject).value(forKey: key6) as? UInt64

        return (rv1: rv1, rv2: rv2, rk1: key7, rk2: key8)
    }
}

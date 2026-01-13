//
//  ApplePoint.swift
//  Pods
//
//  Created by lh900519 on 2026/1/12.
//

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

            // 📍 address 子对象（与 MKMapItem.searchRegion 完全一致）
            let street = [
                placemark.subThoroughfare,
                placemark.thoroughfare,
            ]
            .compactMap { $0 }
            .joined(separator: " ")

            // 📦 顶层 POI 数据（字段与 searchRegion 对齐）
            var detailData: [String: Any] = [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude,
                "name": placemark.name ?? "",

                "street": street,
                "city": placemark.locality ?? "",
                "district": placemark.subLocality ?? "",
                "state": placemark.administrativeArea ?? "",
                "subState": placemark.subAdministrativeArea ?? "",
                "postalCode": placemark.postalCode ?? "",
                "country": placemark.country ?? "",
                "countryCode": placemark.isoCountryCode ?? "",
            ]

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
        completion: @escaping ([[String: Any]]) -> Void
    ) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = point
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )

        let search = MKLocalSearch(request: request)

        search.start { response, error in
            var searchList: [[String: Any]] = []
          
            guard error == nil, let response = response else {
                completion([])
                return
            }

            for item in response.mapItems {
                
                let placemark = item.placemark
                let coord = placemark.coordinate
                
                var detailData: [String: Any] = [
                    "latitude": coord.latitude,
                    "longitude": coord.longitude,
                    "name": item.name ?? "",
                    "url": item.url?.absoluteString ?? "",
                    "isCurrentLocation": item.isCurrentLocation,
                ]
                
                
                // 📍 address 子对象（与 MKMapItem.searchRegion 完全一致）
                let street = [
                    placemark.subThoroughfare,
                    placemark.thoroughfare,
                ]
                .compactMap { $0 }
                .joined(separator: " ")

                detailData["street"] = street
                detailData["city"] = placemark.locality
                detailData["district"] = placemark.subLocality
                detailData["state"] = placemark.administrativeArea
                detailData["postalCode"] = placemark.postalCode
                detailData["country"] = placemark.country
                detailData["countryCode"] = placemark.isoCountryCode

                // POI 分类
                if let category = item.pointOfInterestCategory {
                    detailData["category"] = category.rawValue
                }

                // POI 唯一 ID（iOS 18+）
                if #available(iOS 18.0, *),
                   let id = item.identifier {
                    detailData["id"] = id.rawValue
                }

                // 电话
                if let phone = item.phoneNumber {
                    detailData["phone"] = phone
                }

                // 时区
                if let timeZone = item.timeZone {
                    detailData["timeZone"] = timeZone.identifier
                }

                searchList.append(detailData)
            }

            completion(searchList)
        }
    }
}

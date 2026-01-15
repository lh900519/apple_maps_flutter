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
                print("错误\(String(describing: error))")
                completion([])
                return
            }
            
            for item in response.mapItems {
                var detailData: [String: Any] = [
                    "name": item.name ?? "",
                    "url": item.url?.absoluteString ?? "",
                ]
                
              
//                // iOS 26
//                if #available(iOS 26.0, *) {
//                    let location = item.location
//                    detailData["latitude"] = location.coordinate.latitude
//                    detailData["longitude"] = location.coordinate.longitude
//
//                    if let addressRepresentations = item.addressRepresentations,
//                       let address = item.address {
//                        // POI 地址
//                        detailData["fullAddress"] = address.fullAddress
//                        detailData["shortAddress"] = address.shortAddress ?? ""
//
//                        detailData["city"] = addressRepresentations.cityName ?? ""
//                        detailData["cityWithContext"] = addressRepresentations.cityWithContext ?? ""
//                        detailData["regionName"] = addressRepresentations.regionName ?? ""
//
//                    }
//
//                } else {
                    let placemark = item.placemark
                    let coord = placemark.coordinate
                    detailData["latitude"] = coord.latitude
                    detailData["longitude"] = coord.longitude

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

                    // 兴趣点
                    if let areas = placemark.areasOfInterest, !areas.isEmpty {
                        detailData["areasOfInterest"] = areas
                    }
//                }

                // POI 分类
                if let pointOfInterestCategory = item.pointOfInterestCategory {
                    detailData["pointOfInterestCategory"] = pointOfInterestCategory.rawValue
                }

                // POI 唯一 ID（iOS 18+）
                if #available(iOS 18.0, *) {
                    if let identifier = item.identifier {
                        detailData["identifier"] = identifier.rawValue
                    }

                    detailData["alternateIdentifiers"] = item.alternateIdentifiers.map { $0.rawValue }
                }

                // 电话
                if let phoneNumber = item.phoneNumber {
                    detailData["phoneNumber"] = phoneNumber
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

//
//  ApplePoint.swift
//  Pods
//
//  Created by lh900519 on 2026/1/12.
//

class ApplePointDetail {
  // 逆地理解析（CLPlacemark → 统一 POI 数据结构）
  static func reverseGeocode(
      coordinate: CLLocationCoordinate2D,
      channel: FlutterMethodChannel?
  ) {
      let geocoder = CLGeocoder()
      let location = CLLocation(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude
      )

      geocoder.reverseGeocodeLocation(location) { placemarks, error in
          guard let placemark = placemarks?.first else {
              DispatchQueue.main.async {
                  channel?.invokeMethod("onPOIDetailLoaded", arguments: [:])
              }
              return
          }

          // 📍 address 子对象（与 MKMapItem.searchRegion 完全一致）
          let street = [
              placemark.subThoroughfare,
              placemark.thoroughfare
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
              "countryCode": placemark.ISOcountryCode ?? ""
          ]

          // ⏰ 时区（与 MKMapItem.timeZone 对齐）
          if let timeZone = placemark.timeZone {
              detailData["timeZone"] = timeZone.identifier
          }

          // ⭐ 兴趣点（可选扩展字段）
          if let areas = placemark.areasOfInterest, !areas.isEmpty {
              detailData["areasOfInterest"] = areas
          }

          DispatchQueue.main.async {
              channel?.invokeMethod(
                  "onPOIDetailLoaded",
                  arguments: detailData
              )
          }
      }
  }
  
    // 搜索 POI
    static var currentSearch: MKLocalSearch?

    static func searchRegion(
        point: String,
        coordinate: CLLocationCoordinate2D,
        channel: FlutterMethodChannel?
    ) {
        // 取消上一次搜索，避免重叠 / 回调错乱
        currentSearch?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = point
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 100,
            longitudinalMeters: 100
        )

        let search = MKLocalSearch(request: request)
        currentSearch = search

        search.start { response, error in
            // ❌ 错误处理
            if let error = error {
                print("❌ MKLocalSearch error: \(error)")
                DispatchQueue.main.async {
                    channel?.invokeMethod("onPOIDetailLoaded", arguments: [])
                }
                return
            }

            guard let response = response else {
                DispatchQueue.main.async {
                    channel?.invokeMethod("onPOIDetailLoaded", arguments: [])
                }
                return
            }

            var searchList: [[String: Any]] = []

            for item in response.mapItems {
                let coord = item.location.coordinate

                var detailData: [String: Any] = [
                    "latitude": coord.latitude,
                    "longitude": coord.longitude,
                    "name": item.name ?? "",
                    "url": item.url?.absoluteString ?? "",
                    "isCurrentLocation": item.isCurrentLocation
                ]
              
              
                // ✅ iOS 17 / 18
                let placemark = item.placemark

                // 📍 address 子对象（与 MKMapItem.searchRegion 完全一致）
                let street = [
                    placemark.subThoroughfare,
                    placemark.thoroughfare
                ]
                .compactMap { $0 }
                .joined(separator: " ")
                
                detailData["street"] = street
                detailData["city"] = placemark?.locality
                detailData["district"] = placemark?.subLocality
                detailData["state"] = placemark?.administrativeArea
                detailData["postalCode"] = placemark?.postalCode
                detailData["country"] = placemark?.country
                detailData["countryCode"] = placemark?.isoCountryCode

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

                // 地址（立即 value 化，脱离 MapKit 生命周期）
                let address = extractAddress(from: item)
                detailData["address"] = address

                searchList.append(detailData)
            }

            // Flutter 通道必须回主线程
            DispatchQueue.main.async {
                channel?.invokeMethod(
                    "onPOIDetailLoaded",
                    arguments: searchList
                )
            }
        }
    }

  
    static func extractAddress(from item: MKMapItem) -> [String: Any] {
      var address: [String: Any] = [:]

      // ✅ iOS 26+（未来）
      if #available(iOS 26.0, *) {
          if let addr = item.address {
              address["street"] = addr.street
              address["city"] = addr.city
              address["state"] = addr.state
              address["postalCode"] = addr.postalCode
              address["country"] = addr.country
              address["countryCode"] = addr.countryCode
          }
          return address
      }

      // ✅ iOS 17 / 18
      let placemark = item.placemark

      address["street"] = [
          placemark?.subThoroughfare,
          placemark?.thoroughfare
      ]
      .compactMap { $0 }
      .joined(separator: " ")

      address["city"] = placemark?.locality
      address["district"] = placemark?.subLocality
      address["state"] = placemark?.administrativeArea
      address["postalCode"] = placemark?.postalCode
      address["country"] = placemark?.country
      address["countryCode"] = placemark?.isoCountryCode

      return address
  }
}

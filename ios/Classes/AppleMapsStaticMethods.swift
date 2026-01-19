//
//  AppleMapsStaticMethods.swift
//  Pods
//
//  Created by lh900519 on 2026/1/19.
//

import CoreLocation
import Flutter
import UIKit

public class AppleMapsStaticMethods: NSObject {
    private var methodChannel: FlutterMethodChannel

    public init(with registrar: FlutterPluginRegistrar) {
        methodChannel = FlutterMethodChannel(
            name: "apple_maps_plugin.luisthein.de/static_methods",
            binaryMessenger: registrar.messenger()
        )
        super.init()
        methodChannel.setMethodCallHandler(handleMethodCall)
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args: Dictionary<String, Any> = call.arguments as? Dictionary<String, Any> {
            switch call.method {
            case "reverseGeocode":
                reverseGeocode(args: args, result: result)
                break
            case "searchRegion":
                searchRegion(args: args, result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
                break
            }
        }
    }

    private func reverseGeocode(args: Dictionary<String, Any>, result: @escaping FlutterResult) {
        guard let annotation = args["annotation"] as? [Double] else {
            DispatchQueue.main.async {
                result(nil)
            }
            return
        }
        let coordinate = CLLocationCoordinate2D(
            latitude: annotation[0],
            longitude: annotation[1]
        )
        ApplePointDetail.reverseGeocode(coordinate: coordinate) { data in
            DispatchQueue.main.async {
                result(["data": data])
            }
        }
    }

    private func searchRegion(args: Dictionary<String, Any>, result: @escaping FlutterResult) {
        guard
            let annotation = args["annotation"] as? [Double],
            annotation.count == 2,
            let search = args["search"] as? String,
            let radius = args["radius"] as? Double
        else {
            DispatchQueue.main.async {
                result([])
            }
            return
        }

        let coordinate = CLLocationCoordinate2D(
            latitude: annotation[0],
            longitude: annotation[1]
        )

        ApplePointDetail.searchRegion(
            point: search,
            coordinate: coordinate,
            radius: radius
        ) { list in
            DispatchQueue.main.async {
                result(["data": list])
            }
        }
    }
}

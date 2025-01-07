//
//  TransportApplication.swift
//  Platforma
//
//  Created by Daniil Razbitski on 28/12/2024.
//

import SwiftUI
import CoreLocation

struct TransportApplication: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String // SF Symbol name for icons
    let urlScheme: String
    let fallbackURL: String? // Optional fallback web URL
//    @State private var currentLocation: CLLocation? = nil

    static func getAvailableApps() -> [TransportApplication] {
        let apps = [
            TransportApplication(name: "Uber", iconName: "car", urlScheme: "uber://", fallbackURL: "https://www.uber.com"),
//            TransportApplication(name: "Bolt", iconName: "car.fill", urlScheme: "bolt://", fallbackURL: "https://bolt.eu"),
            TransportApplication(name: "Google Maps", iconName: "map", urlScheme: "comgooglemaps://", fallbackURL: "https://maps.google.com"),
            TransportApplication(name: "Apple Maps", iconName: "map.fill", urlScheme: "maps://", fallbackURL: nil),
            TransportApplication(name: "Waze", iconName: "car.2.fill", urlScheme: "waze://", fallbackURL: "https://www.waze.com")
        ]
        
        // Filter apps that are available on the device
        return apps.filter { app in
            //            if let url = URL(string: "\(app.urlScheme),\(StateContent.addressOpenApp)") {
            if let url = URL(string: app.urlScheme) {
                return UIApplication.shared.canOpenURL(url)
            }
            return false
        }
    }
    //    uber://?action=setPickup&dropoff[formatted_address]=<address>
    //    bolt://requestRide?destination=<address>
    //    comgooglemaps://?daddr=<address>&directionsmode=driving
    //    maps://?daddr=<address>
    //    waze://?q=<address>&navigate=yes
    
    func geocodeAddress(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemark = placemarks?.first {
                let coordinate = placemark.location?.coordinate
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    func open() {
        if let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) {
            let encodedAddress = StateContent.addressOpenApp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            print("url: \(url)")
            print("StateContent.addressOpenApp: \(StateContent.addressOpenApp)")
            //            var geoResult: CLLocationCoordinate2D?
            geocodeAddress(address: StateContent.addressOpenApp, completion: { result in
//                print("result geo: \(result)")
                switch url.absoluteString {
                case "uber://":
                    let urlString = "uber://?action=setPickup&pickup=my_location&dropoff[latitude]=\(result?.latitude ?? 0.0)&dropoff[longitude]=\(result?.longitude ?? 0.0)&dropoff[formatted_address]=\(encodedAddress)"
                    
                    UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
                case "bolt://":
                        let urlString = "bolt://ride?destination=\(result?.latitude ?? 0.0),\(result?.longitude ?? 0.0)"

                        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
                    //                UIApplication.shared.open(URL(string: "bolt://requestRide?destination=\(encodedAddress)")!, options: [:], completionHandler: nil)
                case "comgooglemaps://":
                    UIApplication.shared.open(URL(string: "comgooglemaps://?daddr=\(encodedAddress)&directionsmode=driving")!, options: [:], completionHandler: nil)
                    //                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case "maps://":
                    UIApplication.shared.open(URL(string: "maps://?daddr=\(encodedAddress)")!, options: [:], completionHandler: nil)
                    //                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case "waze://":
                    UIApplication.shared.open(URL(string: "waze://?q=\(encodedAddress)&navigate=yes")!, options: [:], completionHandler: nil)
                    //                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                default:
                    return
                }
            })
            
            //            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if let fallback = fallbackURL, let url = URL(string: fallback) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // Get the user's current location
//    func getCurrentLocation() {
//        if CLLocationManager.locationServicesEnabled() {
//            let locationManager = CLLocationManager()
//            locationManager.requestWhenInUseAuthorization()
//            let locationDelegate = LocationDelegate { location in
//                self.currentLocation = location
//            }
//            locationManager.delegate = locationDelegate
//            locationManager.startUpdatingLocation()
//        }
//    }
    
}

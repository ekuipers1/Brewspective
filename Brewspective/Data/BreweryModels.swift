//
//  BreweryModels.swift
//  Brewspective
//
//  Created by Erik Kuipers on 29.04.24.
//

import CoreLocation

struct BreweryDetail: Codable, Identifiable {
    let id: String
    let name: String
    let brewery_type: String
    let street: String?
    let city: String?
    let postal_code: String?
    let state_province: String?
    let country: String?
    let phone: String?
    let website_url: String?
    let longitude: String?
    let latitude: String?

    var location: CLLocationCoordinate2D {
        guard let lat = latitude, let lon = longitude,
              let latitudeDouble = Double(lat), let longitudeDouble = Double(lon) else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        return CLLocationCoordinate2D(latitude: latitudeDouble, longitude: longitudeDouble)
    }
}

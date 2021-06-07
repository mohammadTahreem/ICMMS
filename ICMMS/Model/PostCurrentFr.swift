//
//  PostCurrentFr.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation

struct PostCurrentFr: Codable {
    var geolocation: Geolocation
    var frId: String
}

struct LocationScanModel: Codable {
    var locationCode, frId: String
    var geoLocation: Geolocation
}

//
//  RequestForPauseModel.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 21/04/21.
//

import Foundation

struct RequestForPauseModel: Codable {
    
    var eotType, eotTime, frId, observation, actionTaken: String?
    var remarks: [String]
    
}

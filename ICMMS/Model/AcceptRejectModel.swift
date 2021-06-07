//
//  AcceptRejectModel.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 22/04/21.
//

import Foundation

struct AcceptRejectModel: Codable {
    
    var frId, observation, actionTaken, fmmDocForAuthorize: String?
    var remarks: [String]?
    
}

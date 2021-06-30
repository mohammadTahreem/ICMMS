//
//  UpdatePmTaskRequest.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 14/04/21.
//

import Foundation

struct UpdatePmTaskRequest: Codable {
    var status: String?
    var remarks: [String]?
    var completedTime, completedDate, taskId: Int?
    var acknowledger: Acknowledger?
    var tech_signature: String?
}

//
//  PmTaskResponse.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 24/03/21.
//

import Foundation

struct PmTaskResponse: Codable, Identifiable {
    var taskNumber, status, endDate, completedBy, completedTime, dueDate,
        buildingName, locationName: String?
    var scheduleDate, completedDate, id: Int?
    var beforeImage, afterImage: BeforeImage?
    var equipment: Equipment?
    var acknowledger: Acknowledger?
    var schedule: Schedule?
    var remarks: [String]?
    var building: Building?
    var location: Location?
    var tech_signature: String?
}


struct BeforeImage: Codable {
    var name, image: String?
    var id: Int?
}

struct Acknowledger: Codable {
    var rank, signature, name: String?
}

struct Schedule: Codable {
    var scheduleNumber, briefDescription: String?
}


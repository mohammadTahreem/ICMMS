//
//  TaskSearchResponse.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 23/03/21.
//

import Foundation

struct TaskSearchResponse: Codable, Hashable {
    var acknowledgementTime, briefDescription, buildingName, completedBy,  completedDate, completedTime, dueDate, endDate,
        equipmentCode, equipmentName, locationName, remarks, scheduleNumber, status, taskNumber, beforeImage, afterImage: String?
    var buildingId, locationId, scheduleDate, taskId: Int?
    
    
}

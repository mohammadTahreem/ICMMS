//
//  GetTasksOnEquipmentModel.swift
//  ICMMS
//
//  Created by Tahreem on 01/07/21.
//

import Foundation


struct GetTasksOnEquipmentModel: Codable, Identifiable {
    var id: Int?
    var tech_signature, equipmentName, buildingName, locationName, status, taskNumber, completedBy, dueDate, completedTime, endDate: String?
    var scheduleDate, completedDate: Int?
    var remarks: [String]?
    var equipment: Equipment?
}

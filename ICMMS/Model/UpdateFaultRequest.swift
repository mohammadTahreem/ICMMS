//
//  UpdateFaultRequest.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation

struct UpdateFaultRequest: Codable {
    var acknowledgerCode, frId, requestorName, requestorContactNo,
        locationDesc, faultCategoryDesc: String?
    var acknowledgedBy: AcknowledgedBy?
    var building: Building?
    var location: Location?
    var department: Division?
    var faultCategory: Division?
    var priority, maintGrp: Division?
    var division: Division?
    var observation, diagnosis, actionTaken, status: String?
    var equipment: Equipment?
    var costCenter: Division?
    var remarks: [String]?
    var attendedBy: [AttendedBy]?
    var eotTime, eotType, activationTime,
        technicianSignature, arrivalTime, restartTime,
        responseTime, downTime, pauseTime, completionTime,
        acknowledgementTime, reportedDate: String?
    var fmm: Fmm?
}




//
//  FaultSearchResponse.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation


struct FaultSearchResponse: Codable, Hashable {
    var activationTime : String?
    var frId, clientFrId, customerRefId, requestorName, requestorContactNo, location,
        building, division, locationDesc, faultCategory, faultCategoryName, priority,
        department, maintGrp, status, reportedTime, equipment, observation, actionTaken, remarks, startDate,
        endDate, startTime, endTime, costCenter, labourHrs, buildingName, locationName : String?
    var reportedDate : String?
    var longitude,latitude : Double?
    
}

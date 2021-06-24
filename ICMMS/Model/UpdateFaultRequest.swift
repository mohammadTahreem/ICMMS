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
}


/*
 
 
 private String acknowledgerCode;
 private AcknowledgedBy acknowledgedBy = null;
 private String frId;
 private String technicianSignature;
 private Building building;
 private Location location;
 private String requestorName;
 private Department department;
 private String requestorContactNo;
 
 private String locationDesc;
 
 private FaultCategory faultCategory;
 
 private String faultCategoryDesc;
 
 private Priority priority;
 
 private MaintGrp maintGrp;
 
 private Division division;
 
 private String observation;
 
 private String diagnosis;
 
 private String actionTaken;
 
 private CostCenter costCenter = null;
 
 private String status;
 
 private Equipment equipment = null;
 
 private List<String> remarks = null;
 
 private ArrayList<AttendedBy> attendedBy;
 */

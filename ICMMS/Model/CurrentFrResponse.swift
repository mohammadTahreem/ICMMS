//
//  CurrentFrResponse.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation


struct EquipmentSearchClass: Codable {
    var equipmentCode: String?
    var frId: String?
}

struct CheckIfCompletedRecently: Codable {
    var editable: String?
}

struct CurrentFrResponse: Codable {
    var frId : String?
    var clientFrId : String?
    var customerRefId : String?
    var requestorName : String?
    var requestorContactNo : String?
    var location : Location?
    var building : Building?
    var division : Division?
    var locationDesc : String?
    var faultCategory : Division?
    var priority : Division?
    var department : Division?
    var maintGrp : Division?
    var remarks : [String]?
    var status : String?
    var faultCategoryDesc : String?
    var locationName : String?
    var buildingName : String?
    var cost : String?
    var editable : Bool?
    var quotationStatus : String?
    var acknowledgerCode : String?
    var purchaseOrder : String?
    var fmmDocForAuthorize : String?
    var acknowledgedBy : AcknowledgedBy?
    var eotType : String?
    var equipment : Equipment?
    var observation : String?
    var actionTaken : String?
    var costCenter : String?
    var labourHrs : String?
    var attendedBy : [AttendedBy]?
    var images : String?
    var activationTime : String?
    var arrivalTime : String?
    var restartTime : String?
    var locationScanned : Bool?
    var responseTime : String?
    var downTime : String?
    var pauseTime : String?
    var completionTime : String?
    var acknowledgementTime : String?
    var eotTime : String?
    var technicianSignature: String?
    var reportedDate: String?
    
    
}

struct Equipment: Codable {
    var equipmentCode: String?
    var name: String?
    var id: Int?
    var building: Building?
    var location: Location?
}

struct AcknowledgedBy: Codable {
    var id : Int?
    var frId: String?
    var taskId: Int?
    var rank: String?
    var signature: String?
    var name: String?
}


struct Location: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var geoLocation: Geolocation?
    var locationCode: String?
    var nameEncrypter: String?
}

struct Building: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var geoLocation: Geolocation?
    var buildingCode: String?
    var nameEncrypter: String?
}

struct Division: Codable {
    var id: Int?
    var name: String?
    var description: String?
}


struct AttendedBy: Codable, Hashable, Identifiable {
    var id: Int?
    var username: String?
    var deviceToken: String?
    var name: String?
}

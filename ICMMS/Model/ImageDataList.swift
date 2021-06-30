//
//  ImageDataList.swift
//  ICMMS
//
//  Created by Tahreem on 22/06/21.
//

import Foundation


struct ImageDataList : Hashable{
    var imageData: Data
    var imageName: String
    var reName, reContact: String?
}


struct CloseFaultReport: Encodable {
    var remarks: [String]?
    var frId, status, username : String?
    var building: Building?
    var location: Location?
    var attendedBy: [AttendedBy]?
}

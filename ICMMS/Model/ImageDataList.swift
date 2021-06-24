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
}


struct CloseFaultReport: Encodable {
    /*
     private List<String> remarks = null;
     String frId, status;
     private Building building;
     private Location location;
     private ArrayList<AttendedBy> attendedBy;
     private String username;*/
    
    
    var remarks: [String]?
    var frId, status, username : String?
    var building: Building?
    var location: Location?
    var attendedBy: [AttendedBy]?
}

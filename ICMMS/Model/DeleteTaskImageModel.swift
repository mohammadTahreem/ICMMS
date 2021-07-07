//
//  DeleteTaskImageModel.swift
//  ICMMS
//
//  Created by Tahreem on 02/07/21.
//

import Foundation


struct DeleteTaskImageModel: Codable {
    var taskId: Int?
    var image, type: String?
    var id: Int?
    
}

struct UploadTaskImageResponse: Codable {
    var id: Int?
    var image, name, contactNo, type: String?
}

//
//  UploadPictureRequestModel.swift
//  ICMMS
//
//  Created by Tahreem on 21/06/21.
//

import Foundation

struct UploadPictureRequestModel: Codable {
    var frId, image, name, contactNo, division, rank,  sign : String?
}

struct UploadTaskImageModel: Codable {
    var taskId, image, name, contactNo, division, rank,  type : String?
}


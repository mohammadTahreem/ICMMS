//
//  FRImageResponseModel.swift
//  ICMMS
//
//  Created by Tahreem on 18/06/21.
//

import Foundation


struct FRImageResponseModel: Codable {
   
    var type, image, name, contactNo, frId: String?
    var id: Int?
}

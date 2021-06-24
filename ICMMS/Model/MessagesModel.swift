//
//  MessagesModel.swift
//  ICMMS
//
//  Created by Tahreem on 24/06/21.
//

import Foundation


struct MessagesModel: Decodable, Hashable {
    var title, text, createdDate, type: String?
    var id : Int?
}

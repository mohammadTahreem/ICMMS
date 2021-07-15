//
//  MessagesModel.swift
//  ICMMS
//
//  Created by Tahreem on 24/06/21.
//

import Foundation


struct MessagesModel: Codable, Hashable {
    var title, text, createdDate, type: String?
    var id : Int?
    var seen: Bool?
    var extras: Extras?
}

struct MessageCountModel: Codable, Hashable {
    var count: Int
    var messages: [MessagesModel]
}

struct Extras: Codable, Hashable {
    var id: String?
    var workspace: String?
}

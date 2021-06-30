//
//  ChecklistModel.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 19/04/21.
//

import Foundation

struct ChecklistModel: Codable, Hashable {
    var description, remarks, status, taskId: String?
    var id: Int?
}

struct UpdateCheckListModel: Codable, Hashable {
    //{"id":1,"remarks":"1","status":"Yes","taskId":1}
    var id, taskId: Int?
    var remarks, status: String?
}

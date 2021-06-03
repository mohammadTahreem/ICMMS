//
//  LoginResponse.swift
//  ICMMS
//
//  Created by Tahreem on 02/06/21.
//

import Foundation

struct LoginResponse: Codable, Hashable {
    var token: String?
    var role: String?
    var username: String?
}

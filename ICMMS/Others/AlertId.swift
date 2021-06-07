//
//  AlertFile.swift
//  ICMMS
//
//  Created by Tahreem on 04/06/21.
//

import SwiftUI

struct AlertId: Identifiable {
    
    var id: AlertType
    
    enum AlertType {
        case respone200
        case response204
        case response422
        case response400
    }
}
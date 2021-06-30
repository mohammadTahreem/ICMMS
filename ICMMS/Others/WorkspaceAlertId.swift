//
//  AlertIDD.swift
//  ICMMS
//
//  Created by Tahreem on 16/06/21.
//

import Foundation


struct WorkspaceAlertId: Identifiable {
    var id: ResponseAlertTypes
    
    enum ResponseAlertTypes {
        case responseTimeOut
        case errorAlert
        case loginAlert
    }
}

enum EditFaultActiveSheet: Identifiable {
    case upQuoSheetCase, second, upPurSheetCase
    
    var id: Int {
        hashValue
    }
}

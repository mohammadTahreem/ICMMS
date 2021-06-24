//
//  AcceptRejectQuotationModel.swift
//  ICMMS
//
//  Created by Tahreem on 24/06/21.
//

import Foundation

struct AcceptRejectQuotationModel: Codable {
    var frId, quotationStatus: String
    var remarks: [String]
}

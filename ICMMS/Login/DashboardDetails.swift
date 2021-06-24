//
//  DashboardDetails.swift
//  ICMMS
//
//  Created by Tahreem on 02/06/21.
//

import Foundation

enum ViewList {
    case searchFaultReportView
    case scanFaultReportView
    case searchPOView
    case searchQoutView
    //case taskScanView
    //case taskSearchView
}

struct DashboadDetails: Identifiable, Hashable {
    let id = UUID()
    let imageName : String
    let itemName: String
    let viewName: ViewList
}

extension DashboadDetails{
    static let demo = [
        DashboadDetails(imageName: "searchfault", itemName: "Search Fault Report", viewName: .searchFaultReportView),
        DashboadDetails(imageName: "scanfault", itemName: "Scan Fault Report", viewName: .scanFaultReportView),
        DashboadDetails(imageName: "purchase_order", itemName: "Search Purchase Order", viewName: .searchPOView),
        DashboadDetails(imageName: "purchase_qoutation", itemName: "Upload Qoutation", viewName: .searchQoutView),
//        DashboadDetails(imageName: "taskscan", itemName: "Task Scan", viewName: .taskScanView),
//        DashboadDetails(imageName: "tasksearch", itemName: "Task Search", viewName: .taskSearchView),
    ]
}

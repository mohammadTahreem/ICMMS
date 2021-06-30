//
//  TaskScanView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 15/03/21.
//

import SwiftUI

struct TaskScanView: View {
    
    @State var showScanSheet: Bool = false
    @State var QRValue: String = ""
    @State var frId: String = ""
    @State var responseCode = ""
    
    var body: some View {
        EquipScanView(showScanSheet: $showScanSheet, QRValue: $QRValue, frId: frId, responseCode: $responseCode)
    }
}

struct TaskScanView_Previews: PreviewProvider {
    static var previews: some View {
        TaskScanView()
    }
}

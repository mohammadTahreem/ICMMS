//
//  EquipScanView.swift
//  ICMMS
//
//  Created by Tahreem on 07/06/21.
//

import SwiftUI
import CarBode
import AVFoundation

struct EquipScanView: View {
    @Binding var showScanSheet : Bool
    @State var qrValue = ""
    @State var cameraPosition = AVCaptureDevice.Position.back
    @State var frId: String
    @Binding var responseCode: String 
    var body: some View {
        CBScanner(
            supportBarcode: .constant([.qr, .code128]),
            scanInterval: .constant(5.0),
            cameraPosition: $cameraPosition
        ){
            print("BarCodeType =",$0.type.rawValue, "Value =",$0.value)
            if $0.value != "" {
                qrValue = $0.value
            }
        }
    }
}

//struct EquipScanView_Previews: PreviewProvider {
//    static var previews: some View {
//        EquipScanView(showScanSheet: <#Binding<Bool>#>, frId: <#String#>, responseCode: <#Binding<String>#>)
//    }
//}

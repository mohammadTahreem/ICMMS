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
    @Binding var QRValue : String
    @State var cameraPosition = AVCaptureDevice.Position.back
    @State var frId: String
    @Binding var responseCode: String 
    var body: some View {
        ZStack{
            Color(.black).ignoresSafeArea()
            CBScanner(
                supportBarcode: .constant([.qr, .code128]),
                scanInterval: .constant(5.0),
                cameraPosition: $cameraPosition
            ){
                print("BarCodeType =",$0.type.rawValue, "Value =",$0.value)
                if $0.value != "" {
                    QRValue = $0.value
                    showScanSheet = false
                    responseCode = String(Int(200))
                }
            }
            onDraw: {
                let lineWidth: CGFloat = 2
                let lineColor = UIColor.red
                
                let fillColor = UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.4)
                
                $0.draw(lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
            }
            .cornerRadius(10)
            .padding(30)
        }
    }
}

//struct EquipScanView_Previews: PreviewProvider {
//
//     var frId = "kasjd"
//     var showscan = false
//     var resCode = false
//     var qrValue = "alskjdn"
//
//    static var previews: some View {
//        EquipScanView(showScanSheet: showscan, qrValue: qrValue , frId: frId, responseCode: resCode)
//    }
//}

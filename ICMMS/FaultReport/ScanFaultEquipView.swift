//
//  ScanFaultEquipView.swift
//  ICMMS
//
//  Created by Tahreem on 07/07/21.
//

import SwiftUI
import CarBode
import AVFoundation

struct ScanFaultEquipView: View {
    @EnvironmentObject var settings: UserSettings
    @State var cameraPosition = AVCaptureDevice.Position.back
    @State private var isScanSuccess: Bool = false
    @State var qrValue: String = ""
    
    var body: some View {
        VStack{
            if isScanSuccess{
                EditFaultReportView(frId: "", QRValue: qrValue, viewFrom: CommonStrings().scanEquipment)
            }else{
                CBScanner(
                    supportBarcode: .constant([.qr, .code128]),
                    scanInterval: .constant(5.0),
                    cameraPosition: $cameraPosition
                ){
                    print("BarCodeType =",$0.type.rawValue, "Value =",$0.value)
                    if $0.value != "" {
                        qrValue = $0.value
                        isScanSuccess = true
                    }
                }
                onDraw: {
                    let lineWidth: CGFloat = 2
                    let lineColor = UIColor.red
                    
                    let fillColor = UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.4)
                    
                    $0.draw(lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
                }
                
                .cornerRadius(10)
                .padding()
                .background(Color(.black)).ignoresSafeArea()
            }
        }.navigationBarTitle("Scan Equipment")
        .navigationBarItems(trailing: Logout().environmentObject(settings))
    }
}

struct ScanFaultEquipView_Previews: PreviewProvider {
    static var previews: some View {
        ScanFaultEquipView()
    }
}

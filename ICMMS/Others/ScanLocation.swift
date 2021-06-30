//
//  ScanEquipOrLocationView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 20/03/21.
//

import SwiftUI
import CarBode
import AVFoundation

struct ScanLocation: View {
    @Binding var showScanSheet : Bool
    @State var qrValue = ""
    @State var cameraPosition = AVCaptureDevice.Position.back    
    @State var frId: String
    @Binding var responseCode: String
    @State var loadingAni : Bool = true
    
    var userLatitude: String
    
    var userLongitude: String

    var body: some View {
        
        if loadingAni {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .onAppear(){
                    if userLatitude != "0" && userLongitude != "0" {
                        loadingAni = false
                    }
                }
        } else {
            CBScanner(
                supportBarcode: .constant([.qr, .code128]), //Set type of barcode you want to scan
                scanInterval: .constant(5.0), //Event will trigger every 5 seconds
                //mockBarCode: .constant(BarcodeData(value:"Mocking data", type: .qr)),
                cameraPosition: $cameraPosition //Bind to switch front/back camera
            ){
                print("BarCodeType =",$0.type.rawValue, "Value =",$0.value)
                if $0.value != "" {
                    qrValue = $0.value
                    locationCall(qrValue: qrValue, userLatitude: userLatitude, userLongitude: userLongitude)
                }
            }
        }
    }
    
    func locationCall(qrValue: String, userLatitude: String, userLongitude: String)  {
        let geolocation = Geolocation(latitude: Double(String(userLatitude))!, longitude: Double(String(userLongitude))!)
        let locationScanModel = LocationScanModel(locationCode: qrValue, frId: frId , geoLocation: geolocation)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/scan/location") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        let encodedBody = try? JSONEncoder().encode(locationScanModel)
        urlRequest.httpBody = encodedBody
        print(locationScanModel)
                        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                return
            }
            responseCode = String(Int(response.statusCode))
            showScanSheet = false
            print("The response code is: \(responseCode)")
        }
        dataTask.resume()
    }
}

struct ScnEquipOrLoc_Preview: PreviewProvider {
    static var previews: some View{
        ScanLocation(showScanSheet: .constant(true), frId: "frId", responseCode: .constant("respons"), userLatitude: "0", userLongitude: "09")
    }
}

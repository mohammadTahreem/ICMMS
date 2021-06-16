//
//  AckWindowView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 26/03/21.
//

import SwiftUI
import PencilKit

struct AcknowledgerFaultView: View {
    
    @Binding var ackSheetBool: Bool
    @State var showErrorAlert : Bool = false
    @State var ackName: String = ""
    @State var ackRank: String = ""
    @State var techSign : String = ""
    @State var ackSign : String = ""
    @State var techSignBool = false
    @State var ackSignBool = false
    @State var ackSignCanvas = PKCanvasView()
    @State var techSignCanvas = PKCanvasView()
    let imgRect = CGRect(x: 0, y: 0, width: 400.0, height: 100.0)
    @State private var onSuccess: Bool = false
    @State private var onFailure: Bool = false
    @State private var isLoading: Bool = false
    @State var dataItems: UpdateFaultRequest
    @State var currentFrResponse : CurrentFrResponse
    @Binding var receivedValueAckFR: String
    
    var body: some View {
        
        
        ZStack{
            Color("light_gray")
                .ignoresSafeArea()
            VStack{
                
                PencilKitRepresentable(canvas: $ackSignCanvas)
                    .frame(height: 100.0)
                    .cornerRadius(8)
                    .border(Color.gray, width: 2)
                    .padding()
                Text("Acknowledger Signature")
                    .font(.caption)
                
                TextField("Name", text: $ackName)
                    .padding()
                    .background(Color("light_gray"))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding()
                TextField("Rank", text: $ackRank)
                    .padding()
                    .background(Color("light_gray"))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                    .padding()
                    .alert(isPresented: $onFailure, content: {
                        Alert(title: Text("Error"), message: Text("Fault Id:\(currentFrResponse.frId ?? "" )  couldn't be updated"), dismissButton: .default(Text("Okay")))
                    })
                
                PencilKitRepresentable(canvas: $techSignCanvas)
                    .frame(height: 100.0)
                    .cornerRadius(8)
                    .border(Color.gray, width: 2)
                    .padding()
                    .alert(isPresented: $onSuccess, content: {
                        Alert(title: Text("Success"), message: Text("Fault: \(currentFrResponse.frId ?? "") is updated successufully"), dismissButton: .default(Text("Okay")){
                            self.ackSheetBool = false
                        })
                    })
                
                Text("Technician Signature")
                    .font(.caption)
                    .padding(.bottom, 5)
                
                
                if isLoading{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }else{
                    
                    Button("Update"){
                        
                        checkForConditions()
                        if !showErrorAlert{
                            updateFaultReport()
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color("Indeco_blue"))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .alert(isPresented: $showErrorAlert, content: {
                        Alert(title: Text("Error"), message: Text("Please fill all fields"), dismissButton: .default(Text("Okay!")))
                    })
                    
                }
                
            }
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .padding()
        }
        
        
    }
    
    
    func checkForConditions() {
        ackSign = saveSignature(canvas: ackSignCanvas)
        techSign = saveSignature(canvas: techSignCanvas)
        print(ackSign)
        techSignBool = techSignCanvas.drawing.strokes.isEmpty
        ackSignBool = ackSignCanvas.drawing.strokes.isEmpty
        
        if (ackName.isEmpty
                || ackRank.isEmpty
                || techSignBool
                || ackSignBool
        ){
            showErrorAlert = true
        }else{
            showErrorAlert = false
        }
    }
    
    func saveSignature(canvas: PKCanvasView) -> String {
        let imageData : UIImage = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1.0)
        let originalImage = imageData.pngData()!
        return originalImage.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    
    func updateFaultReport()  {
        isLoading = true
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        
        dataItems = UpdateFaultRequest(acknowledgerCode: dataItems.acknowledgerCode, frId: dataItems.frId, requestorName: dataItems.requestorName, requestorContactNo: dataItems.requestorContactNo, locationDesc: dataItems.locationDesc, faultCategoryDesc: dataItems.faultCategoryDesc, acknowledgedBy: AcknowledgedBy( frId: dataItems.frId, rank: ackRank, signature: ackSign, name: ackName), building: dataItems.building, location: dataItems.location, department: dataItems.department, faultCategory: dataItems.faultCategory, priority: dataItems.priority, maintGrp: dataItems.maintGrp, division: dataItems.division, observation: dataItems.observation, diagnosis: dataItems.diagnosis, actionTaken: dataItems.actionTaken, status: dataItems.status, equipment: dataItems.equipment, remarks: dataItems.remarks, attendedBy: dataItems.attendedBy, eotTime: dataItems.eotTime, eotType: dataItems.eotType, activationTime: dataItems.activationTime, technicianSignature: techSign, arrivalTime: dataItems.arrivalTime, restartTime: dataItems.restartTime, responseTime: dataItems.responseTime, downTime: dataItems.downTime, pauseTime: dataItems.pauseTime, completionTime: dataItems.completionTime, acknowledgementTime: dataItems.acknowledgementTime, reportedDate: dataItems.reportedDate)
        
        let encodedBody = try? JSONEncoder().encode(dataItems)
        
        urlRequest.httpBody = encodedBody
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                onFailure = true
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                onFailure = true
                return
            }
            
            if response.statusCode == 200 {
                
                guard let _ = data else { return }
                
                if let updateFrResponse = try? JSONDecoder().decode(CurrentFrResponse.self, from: data!){
                    DispatchQueue.main.async {
                        self.currentFrResponse = updateFrResponse
                        print(currentFrResponse)
                    }
                }
                onSuccess = true
                receivedValueAckFR = CommonStrings().successResponse
            } else {
                print("The last print statement: \(data!)")
                print("Error code: \(response.statusCode)")
                onFailure = true
            }
            isLoading = false
        }
        dataTask.resume()
        
    }
    
}

//struct AckWindowView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        var bool1 = Binding<Bool>(get: return true, set:
//        return false)
//
//        AcknowledgerFaultView(ackSheetBool: bool1 , dataItems: UpdateFaultRequest(), currentFrResponse: CurrentFrResponse())
//    }
//}

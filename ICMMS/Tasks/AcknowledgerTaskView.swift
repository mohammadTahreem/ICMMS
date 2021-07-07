//
//  AcknowledgerTaskView.swift
//  ICMMS
//
//  Created by Tahreem on 02/07/21.
//

import SwiftUI
import PencilKit

struct AcknowledgerTaskView: View {
    
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
    @State var tasksDataItems: UpdatePmTaskRequest
    
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
                        Alert(title: Text("Error"), message: Text("Task error" ), dismissButton: .default(Text("Okay")))
                    })
                
                PencilKitRepresentable(canvas: $techSignCanvas)
                    .frame(height: 100.0)
                    .cornerRadius(8)
                    .border(Color.gray, width: 2)
                    .padding()
                    .alert(isPresented: $onSuccess, content: {
                        Alert(title: Text("Success"), message: Text("updated"), dismissButton: .default(Text("Okay")){
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
                    
                    Button(action: {
                        checkForConditions()
                        if !showErrorAlert{
                            updatePmTask()
                        }
                    }, label: {
                        Spacer()
                        Text("Update")
                        Spacer()
                    })
                    .padding()
                    .background(Color("Indeco_blue"))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .padding()
                    
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
    
    func updatePmTask()  {
        
        print("this method called")
        isLoading = true
        tasksDataItems = UpdatePmTaskRequest(status: tasksDataItems.status,
                                             remarks: tasksDataItems.remarks,
                                             completedTime: tasksDataItems.completedTime,
                                             completedDate: tasksDataItems.completedDate,
                                             taskId: tasksDataItems.taskId,
                                             acknowledger: Acknowledger(rank: ackRank, signature: ackSign, name: ackName),
                                             tech_signature: techSign)
        let encodedBody = try? JSONEncoder().encode(tasksDataItems)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)task/updateTask") else {
            return
        }
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = encodedBody
        
        print(urlRequest)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                self.onFailure = true
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                self.onFailure = true
                return
            }
            
            if response.statusCode == 200 {
                guard let _ = data else { return }
                self.onSuccess = true
            } else {
                print("Error code: \(response.statusCode)")
                self.onFailure = true
            }
            isLoading = false
        }
        
        dataTask.resume()
        
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
}

struct AcknowledgerTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgerTaskView(ackSheetBool: .constant(true), tasksDataItems: UpdatePmTaskRequest())
    }
}

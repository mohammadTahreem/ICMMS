//
//  RequestForPauseSheet.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 21/04/21.
//

import SwiftUI

struct RequestForPauseSheet: View {
    @State private var eotList: [String] = []
    @State private var eotTypeSelected: String = "Greater than S$1000"
    @State var requestForPauseModel: RequestForPauseModel
    @State private var eotTime: String = ""
    @State private var updatedAlert: Bool = false
    @State private var errorAlert: Bool = false
    @Binding var requestPauseIsPresented: Bool
    @State private var isLoading = false
    @Binding var closeSheetString : String
    
    var body: some View {
        VStack{
            Text("Fault Cost")
                .padding()
                .font(.title)
                
            Spacer()
            
            VStack{
                Picker("Select EOT Type", selection: $eotTypeSelected) {
                    ForEach(eotList, id: \.self){ eotType in
                        Text(eotType)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                .foregroundColor(.black)
                .padding()
                
                Section(header:
                            HStack{
                                Text("Eot Time")
                                    .foregroundColor(.black)
                                Spacer()
                            }){
                    TextField("Eot Time", text: $eotTime)
                        .onAppear(){
                            eotList.append("Greater than S$1000")
                            eotList.append("Less than S$1000")
                        }.textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .alert(isPresented: $errorAlert, content: {
                            Alert(title: Text("Error"), message: Text("There was an error"), dismissButton: .cancel())
                        })
                }
                .padding()
                ZStack{
                    if isLoading{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }else{
                        Button("Request Pause"){
                            requestPauseFunc()
                        }
                        .padding()
                        .background(Color("Indeco_blue"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding()
                    }
                }
                .alert(isPresented: $updatedAlert, content: {
                    Alert(title: Text("Updated"), message: Text("The request has been sent"), dismissButton: .default(Text("Okay!")){
                        self.requestPauseIsPresented = false
                    })
                })
                .disabled(eotTime.isEmpty)
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color("light_gray"))
            .cornerRadius(8)
            .padding()
            .shadow(radius: 10)
            Spacer()
        }
        .padding()
    }
    
    
    func requestPauseFunc() {
        closeSheetString = "close"
        isLoading.toggle()
        let body : RequestForPauseModel = RequestForPauseModel(eotType: eotTypeSelected, eotTime: eotTime, frId: requestForPauseModel.frId, observation: requestForPauseModel.observation, actionTaken: requestForPauseModel.actionTaken, remarks: requestForPauseModel.remarks)
        
        let encodedBody = try? JSONEncoder().encode(body)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/pauserequest") else { fatalError("Missing URL") }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = encodedBody
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                errorAlert.toggle()
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let _ = data else { return }
                updatedAlert.toggle()
                print(data!)
               /* DispatchQueue.main.async {
                    do {
                        //let decodedUsers = try JSONDecoder().decode(RequestPauseResponse.self, from: data)
                        //self.requestPauseResponse = decodedUsers
                        
                        let decodedResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print(decodedResponse)
                        updatedAlert.toggle()
                    } catch let error {
                        print("Error decoding: ", error)
                        errorAlert.toggle()
                    }
                } */
            }
            isLoading.toggle()
        }
        
        dataTask.resume()
    }
    
}


/*
 struct RequestForPauseSheet_Previews: PreviewProvider {
 static var previews: some View {
 RequestForPauseSheet()
 }
 }
 */

//
//  TaskScanView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 15/03/21.
//

import SwiftUI
import CarBode
import AVFoundation
import Foundation
struct TaskScanView: View {
    
    @State var QRValue: String = ""
    @State var frId: String = ""
    @State var responseCode = ""
    @State var cameraPosition = AVCaptureDevice.Position.back
    @State var dueOverDueSelected: String = CommonStrings().dueTask
    @State var dueOverDueList: [String] = []
    @State var updatedAlert = false
    @State var scanOrPicker: Bool = false
    @EnvironmentObject var settings: UserSettings
    @State private var isLoading = false
    @State var getTasksOnEquipmentModel: [GetTasksOnEquipmentModel] = []
    @State var emptyListBool = false
    @State var isScanSuccess = false
    
    var body: some View {
        
        VStack{
            
            if !scanOrPicker{
                
                    CBScanner(
                        supportBarcode: .constant([.qr, .code128]),
                        scanInterval: .constant(5.0),
                        cameraPosition: $cameraPosition
                    ){
                        print("BarCodeType =",$0.type.rawValue, "Value =",$0.value)
                        if $0.value != "" {
                            QRValue = $0.value
                            scanOrPicker = true
                        }
                    }
                    onDraw: {
                        let lineWidth: CGFloat = 2
                        let lineColor = UIColor.red
                        
                        let fillColor = UIColor(red: 0, green: 1, blue: 0.2, alpha: 0.4)
                        
                        $0.draw(lineWidth: lineWidth, lineColor: lineColor, fillColor: fillColor)
                    }
                    .onAppear(){
                        dueOverDueList.append(CommonStrings().dueTask)
                        dueOverDueList.append(CommonStrings().overdueTask)
                    }
                    .cornerRadius(10)
                    .padding()
                    .background(Color(.black)).ignoresSafeArea()
                
            }else{
                if !isScanSuccess{
                    VStack{
                        Spacer()
                        VStack{
                            Picker("Select EOT Type", selection: $dueOverDueSelected) {
                                ForEach(dueOverDueList, id: \.self){ eotType in
                                    Text(eotType)
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                            .foregroundColor(.black)
                            .padding()
                            
                            
                            if isLoading{
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                            }else{
                                Button("Search Tasks"){
                                    getAllTasksOnEquipment(dueOverDueSelected: dueOverDueSelected)
                                }
                                .padding()
                                .background(Color("Indeco_blue"))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .padding()
                                
                            }
                        }
                        .padding()
                        .background(Color("light_gray"))
                        .cornerRadius(8)
                        .padding()
                        .shadow(radius: 10)
                        Spacer()
                    }
                    .alert(isPresented: $emptyListBool, content: {
                        Alert(title: Text("The list is empty"), dismissButton: .cancel())
                    })
                }else{
                    VStack{
                        List(getTasksOnEquipmentModel){ singlePmTask in
                            ZStack{
                                Button("") {}
                                NavigationLink(destination: PmTaskView(taskId: singlePmTask.id!, viewFrom: CommonStrings().taskScanView)){
                                    TaskScanCardView(taskSearchResponse: singlePmTask)
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationBarTitle(Text("Scan Tasks"))
        .navigationBarItems(trailing: Logout().environmentObject(settings))
    }
    
    
    func getAllTasksOnEquipment(dueOverDueSelected : String)  {
        isLoading = true
        
        var taskType = CommonStrings().dueTaskActual
        
        if dueOverDueSelected == CommonStrings().overdueTask {
            taskType = CommonStrings().overdueTaskActual
        }
        print("\(CommonStrings().apiURL)task/equipment/\(QRValue)/\(taskType)")
        
        let urlString = "\(CommonStrings().apiURL)task/equipment/\(QRValue)/\(taskType)"
        let newUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        
        guard let url = URL(string: newUrlString) else {
            print("error")
            return}
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        print(urlRequest)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                
                guard let _ = data else { return }
                DispatchQueue.main.async {
                    if let equipScanResponse = try? JSONDecoder().decode([GetTasksOnEquipmentModel].self, from: data!){
                        DispatchQueue.main.async {
                            self.getTasksOnEquipmentModel = equipScanResponse
                            
                            if getTasksOnEquipmentModel.isEmpty {
                                emptyListBool = true
                            }else{
                                isScanSuccess = true
                            }
                            
                            print(getTasksOnEquipmentModel)
                        }
                    }else{
                        print("there was an error")
                    }
                }
            }else if response.statusCode == 401 {
                print("error: \(response.statusCode)")
            }
            else{
                print("The last print statement: \(data!) and the error code is: \(response.statusCode)")
            }
            isLoading = false
        }
        dataTask.resume()
    }
}

struct TaskScanView_Previews: PreviewProvider {
    static var previews: some View {
        TaskScanView().environmentObject(UserSettings())
    }
}


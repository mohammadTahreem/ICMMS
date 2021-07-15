//
//  PmTaskView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 24/03/21.
//

import SwiftUI

struct PmTaskView: View {
    
    @State var pmTaskResponse : PmTaskResponse = PmTaskResponse()
    @EnvironmentObject var settings: UserSettings
    @State var isLoadingPm : Bool = true
    @State var remarksList: [String] = []
    @State private var isLoading = false
    @State private var updateAlertBool = false
    @State private var ackSheetBool = false
    @State private var clSheetBool = false
    @State var taskId: Int
    @State var receivedValueAckFR = ""
    @State var viewFrom: String
    @Environment(\.presentationMode) var presentationMode
    @State var showMenuItem1 = false
    @State var showMenuItem2 = false
    @State var showMenuItem3 = false
    @State var showBeforeImageSheet = false
    @State var showAfterImageSheet = false
    @State private var date = Date()
    @State var pickerItem: String = ""
    @State var enableUpdateButton : Bool = false
    @State var statusPickerList : [String] = []
    @State private var currentPmResp : PmTaskResponse = PmTaskResponse()
    
    var body: some View {
        
        let dateInMilis: Int = GeneralMethods().currentTimeInMiliseconds(currentDate: date)
        
        let bodyUpdate = UpdatePmTaskRequest(status: pickerItem, remarks: remarksList, completedTime: dateInMilis, completedDate: dateInMilis, taskId: pmTaskResponse.id, acknowledger: pmTaskResponse.acknowledger, tech_signature: pmTaskResponse.tech_signature)
        
        VStack{
            if isLoadingPm{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .onAppear(){
                        viewPmTask(taskId: taskId)
                    }
            }else{
                ZStack{
                    ScrollView{
                        
                        VStack{
                            
                            if(pmTaskResponse.taskNumber != nil){
                                LabelTextField(label: "Task Number", placeHolder: pmTaskResponse.taskNumber!)
                            }else{
                                LabelTextField(label: "Task Number", placeHolder: "Task Number")
                            }
                            
                            if(pmTaskResponse.schedule != nil && pmTaskResponse.schedule?.scheduleNumber != nil){
                                LabelTextField(label: "Schedule Number", placeHolder: pmTaskResponse.schedule!.scheduleNumber!)
                            }else{
                                LabelTextField(label: "Schedule Number", placeHolder: "Schedule Number")
                            }
                            
                            if( pmTaskResponse.equipment != nil && pmTaskResponse.equipment?.building != nil && pmTaskResponse.equipment?.building?.name != nil){
                                LabelTextField(label: "Building", placeHolder: pmTaskResponse.equipment!.building!.name!)
                            }
                            else{
                                LabelTextField(label: "Building", placeHolder: "Building")
                            }
                            if (pmTaskResponse.equipment != nil && pmTaskResponse.equipment?.location != nil && pmTaskResponse.equipment?.location?.name != nil) {
                                LabelTextField(label: "Location", placeHolder: pmTaskResponse.equipment!.location!.name!)
                            }else{
                                LabelTextField(label: "Location", placeHolder: "Location")
                            }
                            if (pmTaskResponse.equipment?.name != nil) {
                                LabelTextField(label: "Equipment", placeHolder: pmTaskResponse.equipment!.name!)
                            }else{
                                LabelTextField(label: "Equipment", placeHolder: "Equipment")
                            }
                            
                            if(pmTaskResponse.schedule != nil && pmTaskResponse.schedule?.briefDescription != nil){
                                LabelTextField(label: "Brief Description", placeHolder: pmTaskResponse.schedule!.briefDescription!)
                            }else{
                                LabelTextField(label: "Brief Description", placeHolder: "Brief Description")
                            }
                        }
                        
                        VStack{
                            if(pmTaskResponse.scheduleDate != nil){
                                LabelTextField(label: "Schedule Date", placeHolder: String(GeneralMethods().convertLongToDate(isoDate: pmTaskResponse.scheduleDate!)))
                            }else{
                                LabelTextField(label: "Schedule Date", placeHolder: "Schedule Date")
                            }
                            
                            if(pmTaskResponse.completedDate != nil && pmTaskResponse.completedTime != nil){
                                LabelTextField(label: "Completed Date", placeHolder: String(GeneralMethods().convertLongToDate(isoDate: pmTaskResponse.completedDate!)))
                                LabelTextField(label: "Completed Time", placeHolder: pmTaskResponse.completedTime!)
                            }else{
                                VStack {
                                    DatePicker("Completed Date and Time", selection: $date)
                                        .datePickerStyle(DefaultDatePickerStyle())
                                        .frame(maxHeight: 400)
                                        .padding()
                                }
                            }
                            if(pmTaskResponse.completedBy != nil){
                                LabelTextField(label: "Completed By", placeHolder: pmTaskResponse.completedBy!)
                            }else{
                                LabelTextField(label: "Completed By", placeHolder: "Completed By")
                            }
                            
                            VStack{
                                Text("Remarks")
                                    .padding(.horizontal, 15)
                                    .font(.title2)
                                
                                if(pmTaskResponse.remarks != nil){
                                    
                                    ForEach(0..<remarksList.count, id: \.self) { index in
                                        TextField("Remarks", text: Binding<String>(
                                                    get: {remarksList[index] }, set: {remarksList[index] = $0}) )
                                            .padding()
                                            .background(Color("light_gray"))
                                            .foregroundColor(.black)
                                            .cornerRadius(8)
                                            .disabled(!enableUpdateButton)
                                    }
                                    .padding(.horizontal, 10)
                                }
                            }
                            
                            if enableUpdateButton {
                                HStack{
                                    Button(action:{
                                        self.remarksList.append("")
                                    }) {
                                        Text("Add Remarks")
                                    }
                                    Spacer()
                                    Button(action:{
                                        _ = self.remarksList.popLast()
                                    }) {
                                        Text("Delete Remarks")
                                    }
                                }.padding(30)
                            }
                            
                            if(pmTaskResponse.status != nil){
                                
                                if (UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech
                                        && pmTaskResponse.status == "Open") {
                                    
                                    VStack{
                                        
                                        Picker("Select Status",selection: $pickerItem) {
                                            ForEach(GeneralMethods().uniqueElementsFrom(array: statusPickerList) , id:\.self) { val in
                                                Text(val)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .onAppear(){
                                            statusPickerList.removeAll()
                                            statusPickerList.append(pmTaskResponse.status!)
                                            enableDisableMethod(currentPmResponse: pmTaskResponse)
                                        }
                                        .padding()
                                        .onChange(of: pickerItem, perform: { value in
                                            if pickerItem == CommonStrings().statusOpen {
                                                enableUpdateButton = false
                                            }else{
                                                enableUpdateButton = true
                                            }
                                        })
                                        
                                        Text(pickerItem)
                                            .font(.title2)
                                            .padding()
                                        
                                    }
                                    
                                }
                                else{
                                    
                                    VStack{
                                        LabelTextField(label: "Status", placeHolder: pmTaskResponse.status!)
                                        
                                        
                                        if (pmTaskResponse.acknowledger != nil ){
                                            
                                            if(pmTaskResponse.acknowledger?.signature != nil){
                                                let signature: String = pmTaskResponse.acknowledger!.signature!
                                                let url = "\(CommonStrings().apiURL)task/acksignature/\(signature)"
                                                SignView(url: url)
                                            }
                                            
                                            if (pmTaskResponse.acknowledger?.name != nil){
                                                LabelTextField(label: "Acknowledger Name", placeHolder: (pmTaskResponse.acknowledger?.name!)!)
                                            }
                                            if pmTaskResponse.acknowledger?.rank != nil {
                                                LabelTextField(label: "Acknowledger Rank", placeHolder: (pmTaskResponse.acknowledger?.rank!)!)
                                            }
                                        }
                                        
                                        if(pmTaskResponse.tech_signature != nil){
                                           
                                            let signature: String = pmTaskResponse.tech_signature!
                                            let url = "\(CommonStrings().apiURL)task/techsignature/\(signature)"
                                            SignView(url: url)
                                        }
                                        
                                    }
                                    .onAppear(){
                                        enableDisableMethod(currentPmResponse: pmTaskResponse)
                                    }
                                }
                            }else{
                                LabelTextField(label: "Status", placeHolder: "Status")
                            }
                        }
                        
                        if enableUpdateButton {
                            ZStack{
                                if isLoading{
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .padding()
                                }else{
                                    Button("Acknowledge"){
                                        if pickerItem == "Closed"{
                                            ackSheetBool.toggle()
                                        }else{
                                            self.updatePmTaskMethod(bodyUpdate: bodyUpdate)
                                            isLoading = true
                                        }
                                    }.frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Indeco_blue"))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .padding()
                                    .sheet(isPresented: $ackSheetBool, onDismiss: {
                                        updateAlertBool = true
                                    }){
                                        AcknowledgerTaskView(ackSheetBool: $ackSheetBool, tasksDataItems: bodyUpdate)
                                    }
                                    .alert(isPresented: $updateAlertBool, content: {
                                        Alert(title: Text("Successfully Updated!"), dismissButton: .default(Text("Okay!"), action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }))
                                    })
                                }
                            }
                        }
                        
                    }
                    .padding(.top, 10)
                    VStack{
                        Spacer()
                        if showMenuItem1{
                            HStack{
                                Spacer()
                                Button(action: {
                                    showBeforeImageSheet = true
                                }) {
                                    Image("beforeupload")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60)
                                        .background(Color(.white))
                                        .cornerRadius(30)
                                        .shadow(radius: 10)
                                    
                                }
                                .sheet(isPresented: $showBeforeImageSheet, onDismiss: {
                                    pmTaskResponse = PmTaskResponse()
                                    remarksList = []
                                    viewPmTask(taskId: taskId)
                                }) {
                                    ViewTaskImage(ackName: pmTaskResponse.beforeImage?.name ?? "",
                                                  ackContact: pmTaskResponse.beforeImage?.contactNo ?? "" ,
                                                  imageName: pmTaskResponse.beforeImage?.image ?? "", imageType: "Before",
                                                  viewFrom: viewFrom, taskId: String(taskId), id: pmTaskResponse.beforeImage?.id ?? 0,
                                                  status: pmTaskResponse.status!)
                                }
                            }}
                        if showMenuItem2{
                            HStack{
                                Spacer()
                                Button(action: {
                                    showAfterImageSheet = true
                                }) {
                                    Image("afterupload")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60)
                                        .background(Color(.white))
                                        .cornerRadius(30)
                                        .shadow(radius: 10)
                                    
                                }
                                .sheet(isPresented: $showAfterImageSheet, onDismiss: {
                                    pmTaskResponse = PmTaskResponse()
                                    remarksList = []
                                    viewPmTask(taskId: taskId)
                                }){
                                    ViewTaskImage(ackName: pmTaskResponse.afterImage?.name ?? "",
                                                  ackContact: pmTaskResponse.afterImage?.contactNo ?? "",
                                                  imageName: pmTaskResponse.afterImage?.image ?? "", imageType: "After",
                                                  viewFrom: viewFrom, taskId: String(taskId), id: pmTaskResponse.afterImage?.id ?? 0 ,
                                                  status: pmTaskResponse.status!)
                                }
                            }}
                        if showMenuItem3{
                            HStack{
                                Spacer()
                                Button(action:{
                                    clSheetBool.toggle()
                                },
                                label:{
                                    VStack{
                                        Image("listicon_pm")
                                            .resizable()
                                            .padding()
                                            .frame(width: 60, height: 60)
                                            .background(Color(.white))
                                            .cornerRadius(30)
                                            .shadow(radius: 10)
                                    }
                                })
                                .sheet(isPresented: $clSheetBool) {
                                    CheckListSheet(taskId: pmTaskResponse.id!, pmTaskResponse: pmTaskResponse, clSheetBool: $clSheetBool, viewFrom: viewFrom)
                                }
                            }}
                        HStack{
                            Spacer()
                            Button(action: {
                                showMenu()
                            }) {
                                Image("more_icon")
                                    .resizable()
                                    .padding()
                                    .frame(width: 60, height: 60)
                                    .background(Color(.white))
                                    .cornerRadius(30)
                                    .shadow(radius: 10)
                                
                            }
                        }
                    }
                    .padding()
                }
            }
        }.navigationBarTitle("Pm Task")
        .navigationBarItems(trailing: Logout(workspaceViewBool: true, viewFrom: "").environmentObject(settings))
    }
    
    
    func showMenu() {
        showMenuItem3.toggle()
        showMenuItem2.toggle()
        showMenuItem1.toggle()
    }
    
    func enableDisableMethod(currentPmResponse: PmTaskResponse)  {
        pickerItem = currentPmResponse.status!
        remarksList.append(contentsOf: currentPmResponse.remarks!)
        if (currentPmResponse.status == "Closed" ||
                UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameManag){
            enableUpdateButton = false
        }else if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech
                    && viewFrom == CommonStrings().taskScanView {
            statusPickerList.append("Open")
            statusPickerList.append("Closed")
            enableUpdateButton = true
        }
        
    }
    
    
    func updatePmTaskMethod(bodyUpdate: UpdatePmTaskRequest)  {
        let encodedBody = try? JSONEncoder().encode(bodyUpdate)
        
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
        
        URLSession.shared.dataTask(with: urlRequest){ data, _, _ in
            
            if let updatePmTaskResponse = try? JSONDecoder().decode(PmTaskResponse.self, from: data!){
                DispatchQueue.main.async {
                    self.currentPmResp = updatePmTaskResponse
                    print(currentPmResp)
                    updateAlertBool = true
                }
            } else {print("Error: Something went wrong)")
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any] {
                    print(dictionary)
                }
            }
            isLoading = false
        }.resume()
        
        
    }
    
    func viewPmTask(taskId: Int) {
        guard let url = URL(string: "\(CommonStrings().apiURL)task/\(taskId)") else {return}
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        print(urlRequest)
        
        URLSession.shared.dataTask(with: urlRequest){data , _, error  in
            
            if let pmTaskResponse = try? JSONDecoder().decode(PmTaskResponse.self, from: data!){
                DispatchQueue.main.async {
                    self.pmTaskResponse = pmTaskResponse
                    print(pmTaskResponse)
                    isLoadingPm = false
                }
            }else{
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any] {
                    print("Error decoding: \(dictionary)")
                }
            }
            
        }.resume()
    }
    
}


struct PmTaskView_Previews: PreviewProvider {
    static var previews: some View {
        PmTaskView(taskId: 1, viewFrom: "")
            .environmentObject(UserSettings())
    }
}

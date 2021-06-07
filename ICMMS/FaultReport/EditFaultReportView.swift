//
//  EditFaultReportView.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import SwiftUI
import PencilKit

struct EditFaultReportView: View {
    @State var frId : String
    @State var currentFrResponse: CurrentFrResponse = CurrentFrResponse()
    @State var showEditButton : Bool = false
    @EnvironmentObject var settings: UserSettings
    @State var acksheetBool : Bool = false
    
    var body: some View {
        
        ScrollView{
            ViewFaultReport( currentFrResponse: currentFrResponse, frId: frId, acksheetBool: $acksheetBool)
        }
        .onAppear(){
            getCurrentFaultReport(frId: frId)
        }
        .toolbar(){
            ToolbarItem(placement: .navigationBarTrailing){
                Logout().environmentObject(settings)
            }
        }
        .navigationBarTitle("Edit Fault Report")
        
    }
    // FIXME:
    
    func getCurrentFaultReport(frId: String)  {
        let body = PostCurrentFr(geolocation: Geolocation( latitude: 0, longitude: 0), frId: frId)
        let encoded = try? JSONEncoder().encode(body)
        
        let urlString = "\(CommonStrings().apiURL)faultreport/findOne"
        
        guard let url = URL(string: urlString) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = encoded
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let _ = data else { return }
                DispatchQueue.main.async {
                    do {
                        let currentFrResponse = try JSONDecoder().decode(CurrentFrResponse.self, from: data!)
                        self.currentFrResponse = currentFrResponse
                        showEditButton = true
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }else if response.statusCode == 401 {
                print("error: \(response.statusCode)")
            }
            else{
                print("The last print statement: \(data!)")
            }
        }
        
        dataTask.resume()
    }
    
}


struct ViewFaultReport : View {
    
    @State var showSheetView: Bool = false
    @State var showLocationButton: Bool = false
    @State var showEquipButton: Bool = false
    @State var showRequestPauseButton = false
    @State var showAcceptReject = false
    @State var showUpdateButton = false
    @State var showScanSheet = false
    @State var ackName = ""
    @State var ackRank = ""
    @State var observationString = ""
    @State var actionTakenString = ""
    var currentFrResponse: CurrentFrResponse
    @State var frId: String
    @State var pickerItem = ""
    @State var statusPickerList : [String] = []
    @State var remarksList: [String] = []
    @State private var isLoading: Bool = false
    @State private var requestPauseIsPresented: Bool = false
    @State private var acceptSheetBool: Bool = false
    @Binding var acksheetBool : Bool
    @State var responseCode: String = ""
    @State var responseAlert: Bool = false
    @State var alertId: AlertId?

    
    var body: some View{
        
        let updateFaultReportRequest : UpdateFaultRequest = UpdateFaultRequest(acknowledgerCode: currentFrResponse.acknowledgerCode, frId: currentFrResponse.frId, requestorName: currentFrResponse.requestorName, requestorContactNo: currentFrResponse.requestorContactNo, locationDesc: currentFrResponse.locationDesc, faultCategoryDesc: currentFrResponse.faultCategoryDesc, acknowledgedBy: currentFrResponse.acknowledgedBy, building: currentFrResponse.building, location: currentFrResponse.location, department: currentFrResponse.department, faultCategory: currentFrResponse.faultCategory, priority: currentFrResponse.priority, maintGrp: currentFrResponse.maintGrp, division: currentFrResponse.division, observation: observationString, diagnosis: "", actionTaken: actionTakenString, status: pickerItem, equipment: currentFrResponse.equipment, remarks: remarksList, attendedBy: currentFrResponse.attendedBy)
        
        VStack{
            VStack{
                
                LabelTextField(label: "Case Id", placeHolder: frId)
                    
                
                if(currentFrResponse.department != nil && currentFrResponse.department?.name != nil){
                    LabelTextField(label: "Department", placeHolder: currentFrResponse.department!.name!)
                } else{
                    LabelTextField(label: "Department", placeHolder: "Department")
                }
                
                if(currentFrResponse.requestorName != nil){
                    LabelTextField(label: "Requestor Name", placeHolder: currentFrResponse.requestorName!)
                }else{
                    LabelTextField(label: "Requestor Name", placeHolder: "Requestor Name")
                }
                
                if(currentFrResponse.activationTime != nil){
                    LabelTextField(label: "Activation Date",
                                   placeHolder:GeneralMethods().convertTStringToString(isoDate: currentFrResponse.activationTime!))
                }else{
                    LabelTextField(label: "Activation Date", placeHolder: "Activation Date")
                }
                
                if(currentFrResponse.arrivalTime != nil){
                    LabelTextField(label:"Arrival Date",
                                   placeHolder: GeneralMethods().convertTStringToString(isoDate: currentFrResponse.arrivalTime!))
                }else{
                    LabelTextField(label: "Arrival Date", placeHolder: "Arrival Date")
                }
                
                if(currentFrResponse.responseTime != nil){
                    LabelTextField(label: "Response Time", placeHolder:currentFrResponse.responseTime!)
                }else{
                    LabelTextField(label: "Response Time", placeHolder: "Response Time")
                }
                
                if(currentFrResponse.acknowledgementTime != nil){
                    LabelTextField(label: "Acknowledge Time", placeHolder:GeneralMethods().convertTStringToString(isoDate: currentFrResponse.acknowledgementTime!))
                }else{
                    LabelTextField(label: "Acknowledge Time", placeHolder: "Acknowledge Time")
                }
                
                if(currentFrResponse.downTime != nil){
                    LabelTextField(label: "Down Time", placeHolder:currentFrResponse.downTime!)
                }else{
                    LabelTextField(label: "Down Time", placeHolder: "Down Time")
                }
                
                if(currentFrResponse.eotTime != nil){
                    LabelTextField(label: "EOT", placeHolder:currentFrResponse.eotTime!)
                }else{
                    LabelTextField(label: "EOT", placeHolder: "EOT")
                }
                
                if(currentFrResponse.eotType != nil){
                    LabelTextField(label: "Required EOT Time", placeHolder: currentFrResponse.eotType!)
                }else{
                    LabelTextField(label: "Required EOT Time", placeHolder: "Required EOT Time")
                }
            }
            
            VStack{
                
                VStack{
                    if(currentFrResponse.requestorContactNo != nil){
                        LabelTextField(label: "Contact Number", placeHolder:currentFrResponse.requestorContactNo!)
                    }else{
                        LabelTextField(label: "Contact Number", placeHolder: "Contact Number")
                    }
                    
                    if(currentFrResponse.priority != nil && currentFrResponse.priority?.name != nil) {
                        LabelTextField(label: "Priority", placeHolder:currentFrResponse.priority!.name!)
                    }else{
                        LabelTextField(label: "Priority", placeHolder: "Priority")
                    }
                    
                    if(currentFrResponse.building != nil && currentFrResponse.building?.name != nil) {
                        LabelTextField(label: "Building", placeHolder: currentFrResponse.building!.name!)
                    }else{
                        LabelTextField(label: "Building", placeHolder: "Building")
                    }
                    
                    if(currentFrResponse.location != nil && currentFrResponse.location?.name != nil){
                        LabelTextField(label: "Location", placeHolder: currentFrResponse.location!.name!)
                    }else{
                        LabelTextField(label: "Location", placeHolder: "Location")
                    }
                    
                    if(currentFrResponse.division != nil && currentFrResponse.division?.name != nil){
                        LabelTextField(label: "Division", placeHolder: currentFrResponse.division!.name!)
                    }else{
                        LabelTextField(label: "Division", placeHolder: "Division")
                    }
                    
                    if(currentFrResponse.locationDesc != nil){
                        LabelTextField(label: "Location Description", placeHolder: currentFrResponse.locationDesc!)
                    }else{
                        LabelTextField(label: "Location Description", placeHolder: "Location Description")
                    }
                    
                    if(currentFrResponse.faultCategory != nil && currentFrResponse.faultCategory?.name != nil){
                        LabelTextField(label: "Fault Category", placeHolder: currentFrResponse.faultCategory!.name!)
                    }else{
                        LabelTextField(label: "Fault Category", placeHolder: "Fault Category")
                    }
                    
                    if(currentFrResponse.faultCategoryDesc != nil){
                        LabelTextField(label: "Fault Description", placeHolder: currentFrResponse.faultCategoryDesc!)
                    }else{
                        LabelTextField(label: "Fault Description", placeHolder: "Fault Description")
                    }
                    
                    if(currentFrResponse.maintGrp != nil && currentFrResponse.maintGrp?.name != nil ){
                        LabelTextField(label: "Maintenance Group", placeHolder: currentFrResponse.maintGrp!.name!)
                    }else{
                        LabelTextField(label: "Maintenance Group", placeHolder: "Maintenance Group")
                    }
                }
                VStack{
                    
                    Section(header: HStack{Text("Observation")
                        .font(.headline)
                        Spacer()
                    }){
                        TextField("Observation", text: $observationString)
                            .padding()
                            .background(Color("light_gray"))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 15)
                    
                    Section(header: HStack{Text("ActionTaken")
                        .font(.headline)
                        Spacer()
                    }){
                        TextField("Action Taken", text: $actionTakenString)
                            .padding()
                            .background(Color("light_gray"))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }.padding(.horizontal, 15)
                    
                    
                    if(currentFrResponse.equipment != nil && currentFrResponse.equipment?.name != nil){
                        LabelTextField(label: "Equipment", placeHolder: currentFrResponse.equipment!.name!)
                    }else{
                        LabelTextField(label: "Equipment", placeHolder: "Equipment")
                    }
                }
            }
            .onChange(of: responseCode, perform: { value in
                if Int(String(value)) == 200{
                    self.alertId = AlertId(id: .respone200)
                }else if(Int(String(value)) == 422){
                    self.alertId = AlertId(id: .response422)
                }else if (Int(String(value)) == 204){
                    self.alertId = AlertId(id: .response204)
                }else if Int(String(value)) == 400{
                    self.alertId = AlertId(id: .response400)
                }
            })
            .alert(item: $alertId) { (alertId) -> Alert in
                return createAlert(alertId: alertId)
            }
        
            
            VStack{
                //remarks
                VStack{
                    Text("Remarks")
                        .padding(.horizontal, 15)
                        .font(.title2)
                    
                    ForEach(0..<remarksList.count, id: \.self) { index in
                        TextField("Remarks", text: Binding<String>(
                                    get: {remarksList[index] }, set: {remarksList[index] = $0}) )
                            .padding()
                            .background(Color("light_gray"))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 17)
                    
                    if showUpdateButton || showAcceptReject {
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
                }
                //status
                VStack{
                    if(currentFrResponse.status != nil){
                        VStack{
                            if (showUpdateButton) {
                                Text("Status")
                                    .font(.title2)
                                    .padding()
                                Picker(selection: $pickerItem, label: Text("Status")) {
                                    ForEach(GeneralMethods().uniqueElementsFrom(array: statusPickerList) , id:\.self) { val in
                                        Text(val)
                                    }
                                }
                                .padding()
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            else{
                                LabelTextField(label:"Status", placeHolder: currentFrResponse.status!)
                            }
                        }
                        .onAppear(){
                            statusPickerList.removeAll()
                            statusPickerList.append(currentFrResponse.status!)
                            pickerItem = currentFrResponse.status!
                            enableDisableButtons(currentFrResponse: currentFrResponse)
                        }
                    }
                    else{
                        LabelTextField(label: "Status", placeHolder: "Status")
                    }
                    
                    if(currentFrResponse.attendedBy != nil){
                        VStack() {
                            
                            ForEach (currentFrResponse.attendedBy!, id:\.self){ item in
                                LabelTextField(label: "Attended By", placeHolder: item.name!)
                            }
                        }
                    }
                    else{
                        LabelTextField(label: "Attended By", placeHolder: "Attended By")
                    }
                }
                // ack signature and tech signature
                VStack{
                    if (currentFrResponse.acknowledgedBy != nil &&
                            UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameManag){
                        
                        if(currentFrResponse.acknowledgedBy?.signature != nil){
                            VStack{
                                Text("Acknowledger Signature")
                                    .padding()
                                let signature: String = currentFrResponse.acknowledgedBy!.signature!
                                let url = "\(CommonStrings().apiURL)faultreport/techsignature/\(signature)"
                                URLImage(url: url)
                                    .scaledToFit()
                                    .padding()
                                    .cornerRadius(8)
                            }
                            .background(Color("light_gray"))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .padding()
                        }
                        
                        if (currentFrResponse.acknowledgedBy?.name != nil){
                            LabelTextField(label: "Acknowledger Name", placeHolder: (currentFrResponse.acknowledgedBy?.name!)!)
                        }
                        if currentFrResponse.acknowledgedBy?.rank != nil {
                            LabelTextField(label: "Acknowledger Rank", placeHolder: (currentFrResponse.acknowledgedBy?.rank!)!)
                        }
                    }
                    
                    if(currentFrResponse.technicianSignature != nil &&
                        UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameManag){
                        VStack{
                            Text("Technician Signature")
                                .padding()
                            let signature: String = currentFrResponse.technicianSignature!
                            let url = "\(CommonStrings().apiURL)faultreport/acksignature/\(signature)"
                            URLImage(url: url)
                                .scaledToFit()
                                .padding()
                                .cornerRadius(8)
                        }
                        .background(Color("light_gray"))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .padding()
                    }
                }
                //buttons
                VStack{
                    
                    if showEquipButton {
                        Button("Equipment Scan") {
                            showScanSheet = true
                        }
                        .padding()
                        .background(Color("Indeco_blue"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding()
                        .sheet(isPresented: $showScanSheet, content: {
                            EquipScanView(showScanSheet: $showScanSheet, frId: currentFrResponse.frId!, responseCode: $responseCode)
                        })
                    }else{
                        EmptyView()
                    }
                    
                    if showLocationButton {
                        Button("Location Scan") {
                            showScanSheet = true
                        }
                        .padding()
                        .background(Color("Indeco_blue"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding()
                        .sheet(isPresented: $showScanSheet, content: {
                            ScanEquipOrLocationView(showScanSheet: $showScanSheet, frId: currentFrResponse.frId!, responseCode: $responseCode)
                        })
                    }else{
                        EmptyView()
                    }
                    
                    if showAcceptReject {
                        
                        Button(action: {
                            acceptSheetBool.toggle()
                        }, label: { HStack{
                            Spacer()
                            Text("Accept")
                            Spacer()
                        }})
                        .padding()
                        .background(Color("Indeco_blue"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding()
                        .sheet(isPresented: $acceptSheetBool, content: {
                            AcceptPauseSheet(acceptRejectModel: acceptRejectModelFunc(), acceptSheetBool: $acceptSheetBool)
                        })
                        
                        
                        ZStack{
                            if isLoading{
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                            }else{
                                Button(action: {
                                    acceptRejectCall(acceptReject: "reject")
                                }, label: {
                                    HStack{
                                        Spacer()
                                        Text("Reject")
                                        Spacer()
                                    }
                                })
                                .padding()
                                .background(Color("Indeco_blue"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }.padding()
                    }else{
                        EmptyView()
                    }
                    if showRequestPauseButton {
                        if isLoading{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }else{
                            
                            Button(action: {requestPauseIsPresented.toggle()}, label: { HStack{
                                Spacer()
                                Text("Request Pause")
                                Spacer()
                            }})
                            .padding()
                            .background(Color("Indeco_blue"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .padding()
                            .sheet(isPresented: $requestPauseIsPresented){
                                RequestForPauseSheet(requestForPauseModel: pauseRequestCall(), requestPauseIsPresented: $requestPauseIsPresented)
                            }
                            
                        }
                    }else{
                        EmptyView()
                    }
                    
                    if showUpdateButton {
                        
                        ZStack{
                            if isLoading{
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                            }else{
                                Button(action: {
                                    if (UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech){
                                        if pickerItem == "Open" {
                                            updateFaultReportFunc(updateFaultReportRequest: updateFaultReportRequest)
                                        }else if pickerItem == "Completed"{
                                            acksheetBool = true
                                        }
                                    }
                                    else{
                                        updateFaultReportFunc(updateFaultReportRequest: updateFaultReportRequest)
                                    }
                                }, label: { HStack{
                                    Spacer()
                                    if (UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech){
                                        if pickerItem == "Open" {
                                            Text("Update")
                                        }else{
                                            Text("Acknowledge")
                                        }}
                                    else{
                                        Text("Update")
                                    }
                                    Spacer()
                                    
                                }})
                                .padding()
                                .background(Color("Indeco_blue"))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .padding()
                                .sheet(isPresented: $acksheetBool, content: {
                                    AcknowledgerFaultView(ackSheetBool: $acksheetBool, dataItems: updateFaultReportRequest, currentFrResponse: currentFrResponse)
                                    
                                })
                            }
                        }
                    }else{
                        EmptyView()
                    }
                }
            }
            
        }.padding(.top, 20)
        
    }
    
    private func createAlert(alertId: AlertId) -> Alert {
        print(alertId.id)

        switch alertId.id {
        case .respone200:
            return Alert(title: Text("The location is set"))
        case .response204:
            return Alert(title: Text("You are not at the current location"))
        case .response422:
            return Alert(title: Text("Fault report does not match with the scanned location"))
        case .response400:
            return Alert(title: Text("The QR code seems incorrect"))
        }
    }
    
    func acceptRejectCall(acceptReject: String)  {
        //do something
        if acceptReject == "reject" {
            isLoading.toggle()
        }
        
    }
    
    
    
    func updateFaultReportFunc(updateFaultReportRequest: UpdateFaultRequest) {
        
        isLoading = true
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        let encodedBody = try? JSONEncoder().encode(updateFaultReportRequest)
        
        urlRequest.httpBody = encodedBody
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                return
            }
            
            if response.statusCode == 200 {
                
                guard let _ = data else { return }
                
                if let updateFrResponse = try? JSONDecoder().decode(CurrentFrResponse.self, from: data!){
                    DispatchQueue.main.async {
                        print(updateFrResponse)
                    }
                }
                
            } else {
                print("Error code: \(response.statusCode)")
            }
        }
        isLoading = false
        dataTask.resume()
        
        
    }
    
    func enableDisableButtons(currentFrResponse: CurrentFrResponse){
        print("enable disable method: \(currentFrResponse)")
        if (UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech){
            statusPickerList.append("Open")
            statusPickerList.append("Completed")
            
            if currentFrResponse.status != nil {
                if currentFrResponse.status! == "Pause" {
                    showRequestPauseButton = false
                    statusPickerList.remove(at: self.statusPickerList.firstIndex(of: "Open")!)
                } else if (currentFrResponse.status! == "Pause Requested"
                            || currentFrResponse.status! == "Completed"
                            || currentFrResponse.status! == "Closed"){
                    showUpdateButton = false
                    showRequestPauseButton = false
                }
                
                if currentFrResponse.editable! == false && currentFrResponse.status! == CommonStrings().statusOpen {
                    showLocationButton = true
                }else if currentFrResponse.editable! == true && currentFrResponse.status! == CommonStrings().statusOpen{
                    showEquipButton = true
                }
                
            }
            
        } else if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameManag {
            statusPickerList.append("Open")
            statusPickerList.append("Closed")
            statusPickerList.append("Completed")
            
            if currentFrResponse.status != nil{
                if currentFrResponse.status! == "Pause Requested" {
                    showUpdateButton = false
                    showAcceptReject = true
                }else if currentFrResponse.status! == "Closed" ||
                            currentFrResponse.status! == "Open"{
                    showUpdateButton = false
                    showAcceptReject = false
                }
            }
        }
        
        if currentFrResponse.status != nil { statusPickerList.append(currentFrResponse.status!) }
        
        remarksList.removeAll()
        if currentFrResponse.remarks != nil {
            remarksList.append(contentsOf: currentFrResponse.remarks!)
        }
        
        if currentFrResponse.observation != nil { observationString = currentFrResponse.observation! }
        
        if currentFrResponse.actionTaken != nil { actionTakenString = currentFrResponse.actionTaken! }
        
    }
    
    func pauseRequestCall() -> RequestForPauseModel  {
        var currentRemarksList: [String] = []
        
        for remark in remarksList {
            if currentFrResponse.remarks != nil {
                if !currentFrResponse.remarks!.contains(remark) {
                    currentRemarksList.append(remark)
                }
            }else{
                currentRemarksList.append(remark)
            }
        }
        
        return RequestForPauseModel(eotType: currentFrResponse.eotType, eotTime: currentFrResponse.eotTime, frId: currentFrResponse.frId!, observation: observationString, actionTaken: actionTakenString, remarks: currentRemarksList)
    }
    
    func acceptRejectModelFunc() -> AcceptRejectModel {
        return AcceptRejectModel(frId: currentFrResponse.frId, observation: observationString, actionTaken: actionTakenString, fmmDocForAuthorize: "", remarks: remarksList)
    }
}
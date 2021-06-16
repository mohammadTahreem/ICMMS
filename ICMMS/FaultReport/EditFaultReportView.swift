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
    @EnvironmentObject var settings: UserSettings
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
    @State var pickerItem = ""
    @State var statusPickerList : [String] = []
    @State var remarksList: [String] = []
    @State private var isLoading: Bool = false
    @State private var requestPauseIsPresented: Bool = false
    @State private var acceptSheetBool: Bool = false
    @State var ackSheetBool : Bool = false
    @State var responseCode: String = ""
    @State var locationAlert: Bool = false
    @State var alertId: AlertId?
    @State var QRValue: String = ""
    @State var frIsLoading = true
    @Environment(\.presentationMode) var presentationMode
    @State var selection: Int? = nil
    @State var closeSheetString: String = ""
    @State var receivedValueAckFR = ""
    @State var openQuotationSheet = false
    
    var body: some View {
        
        let updateFaultReportRequest : UpdateFaultRequest = UpdateFaultRequest(acknowledgerCode: currentFrResponse.acknowledgerCode, frId: currentFrResponse.frId, requestorName: currentFrResponse.requestorName, requestorContactNo: currentFrResponse.requestorContactNo, locationDesc: currentFrResponse.locationDesc, faultCategoryDesc: currentFrResponse.faultCategoryDesc, acknowledgedBy: currentFrResponse.acknowledgedBy, building: currentFrResponse.building, location: currentFrResponse.location, department: currentFrResponse.department, faultCategory: currentFrResponse.faultCategory, priority: currentFrResponse.priority, maintGrp: currentFrResponse.maintGrp, division: currentFrResponse.division, observation: observationString, diagnosis: "", actionTaken: actionTakenString, status: pickerItem, equipment: currentFrResponse.equipment, remarks: remarksList, attendedBy: currentFrResponse.attendedBy)
        
        VStack{
            if frIsLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(20)
                    .onAppear(){
                        getCurrentFaultReport(frId: frId)
                    }
            }else{
                ScrollView {
                    VStack{
                        //general items. Not editable
                        GeneralItems(frId: frId, currentFrResponse: currentFrResponse,
                                     observationString: $observationString, actionTakenString: $actionTakenString)
                            .sheet(isPresented: $openQuotationSheet , content: {
                                UploadQuotationView(frId: frId)
                            })
                        
                        VStack{
                            //remarks
                            VStack{
                                Text("Remarks")
                                    .padding(.horizontal, 15)
                                    .font(.title2)
                                    .onChange(of: currentFrResponse.editable) { boovalue in
                                        enableDisableButtons(currentFrResponse: currentFrResponse)
                                    }
                                
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
                                if (currentFrResponse.acknowledgedBy != nil){
                                    
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
                                
                                if(currentFrResponse.technicianSignature != nil){
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
                                    .sheet(isPresented: $showScanSheet, onDismiss: {
                                        if QRValue != "" {
                                            getCurrentFrUsingEquipment(qrValue: QRValue)
                                        }
                                    },content: {
                                        EquipScanView(showScanSheet: $showScanSheet, QRValue: $QRValue, frId: currentFrResponse.frId!, responseCode: $responseCode)
                                            .onAppear(){
                                                QRValue = String()
                                            }
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
                                    .sheet(isPresented: $showScanSheet, onDismiss: {
                                        locationAlert = true
                                        if Int(String(responseCode)) == 200{
                                            self.alertId = AlertId(id: .respone200)
                                        }else if(Int(String(responseCode)) == 422){
                                            self.alertId = AlertId(id: .response422)
                                        }else if (Int(String(responseCode)) == 204){
                                            self.alertId = AlertId(id: .response204)
                                        }else if Int(String(responseCode)) == 400{
                                            self.alertId = AlertId(id: .response400)
                                        }
                                    },content: {
                                        ScanLocation(showScanSheet: $showScanSheet, frId: currentFrResponse.frId!, responseCode: $responseCode)
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
                                        .sheet(isPresented: $requestPauseIsPresented, onDismiss: {
                                            if closeSheetString == "close"{
                                                self.alertId = AlertId(id: .closeFRIfRequestPaused)
                                            }
                                        }){
                                            RequestForPauseSheet(requestForPauseModel: pauseRequestCall(), requestPauseIsPresented: $requestPauseIsPresented, closeSheetString: $closeSheetString)
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
                                                if (pickerItem != currentFrResponse.status!){
                                                    if (UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech){
                                                        if pickerItem == "Open" {
                                                            updateFaultReportFunc(updateFaultReportRequest: updateFaultReportRequest)
                                                        }else if pickerItem == "Completed"{
                                                            ackSheetBool = true
                                                        }
                                                    }
                                                    else{
                                                        updateFaultReportFunc(updateFaultReportRequest: updateFaultReportRequest)
                                                    }
                                                }else{
                                                    self.alertId = AlertId(id: .sameStatusForUpdateAlert)
                                                }
                                            }
                                            , label: { HStack{
                                                Spacer()
                                                if (UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech){
                                                    if pickerItem == CommonStrings().statusOpen || pickerItem == CommonStrings().statusPause {
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
                                            .onChange(of: pickerItem, perform: { picker in
                                                if picker == CommonStrings().statusOpen {
                                                    showRequestPauseButton = true
                                                }else if picker == CommonStrings().statusCompleted{
                                                    showRequestPauseButton = false
                                                }
                                            })
                                            .sheet(isPresented: $ackSheetBool,onDismiss: {
                                                if receivedValueAckFR == CommonStrings().successResponse{
                                                    self.alertId = AlertId(id: .closeFrAfterUpdate)
                                                }
                                            }, content: {
                                                AcknowledgerFaultView(ackSheetBool: $ackSheetBool, dataItems: updateFaultReportRequest, currentFrResponse: currentFrResponse, receivedValueAckFR: $receivedValueAckFR)
                                            })
                                        }
                                    }
                                }else{
                                    EmptyView()
                                }
                            }
                            .alert(item: $alertId) { (alertId) -> Alert in
                                return createAlert(alertId: alertId, updateFaultReportRequest: updateFaultReportRequest, currentStatus: currentFrResponse.status!)
                            }
                        }
                        
                    }.padding(.top, 20)
                }
            }
        }
        .navigationBarItems(trailing: Logout().environmentObject(settings))
        
        .navigationBarTitle("Edit Fault Report")
        
        
    }
    // FIXME:
    
    func getCurrentFaultReport(frId: String)  {
        
        currentFrResponse = CurrentFrResponse()
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
                frIsLoading = false
                guard let _ = data else { return }
                DispatchQueue.main.async {
                    do {
                        let frResponseOnSearch = try JSONDecoder().decode(CurrentFrResponse.self, from: data!)
                        self.currentFrResponse = frResponseOnSearch
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
    
    func getCurrentFrUsingEquipment(qrValue: String) {
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/equipment") else {return}
        
        let body = EquipmentSearchClass(equipmentCode: qrValue, frId: frId)
        let encodedBody = try? JSONEncoder().encode(body)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = encodedBody
        
        URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            
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
                self.alertId = AlertId(id: .responseEquip200)
                if let currentFrEquip = try? JSONDecoder().decode(CurrentFrResponse.self, from: data!){
                    DispatchQueue.main.async {
                        self.currentFrResponse = currentFrEquip
                        print("success QR code")
                        print("the response from equip scan is: \(currentFrResponse)")
                    }
                }
            } else if response.statusCode == 214{
                self.alertId = AlertId(id: .response214)
            }else if response.statusCode == 215{
                self.alertId = AlertId(id: .response215)
            }else if response.statusCode == 216{
                self.alertId = AlertId(id: .response216)
            }else {
                print("Error code: \(response.statusCode)")
            }
            print(response.statusCode)
        }
        .resume()
    }
    
    private func createAlert(alertId: AlertId, updateFaultReportRequest: UpdateFaultRequest, currentStatus: String) -> Alert {
        switch alertId.id {
        case .respone200:
            return Alert(title: Text("The location is set"), dismissButton: .default(Text("Okay"), action: {
                print("location clicked")
                getCurrentFaultReport(frId: frId)
            }))
        case .response204:
            return Alert(title: Text("You are not at the current location"), dismissButton: .cancel())
        case .response422:
            return Alert(title: Text("Fault report does not match with the scanned location"), dismissButton: .cancel())
        case .response400:
            return Alert(title: Text("Geo-Location is not assigned to this fault report"), dismissButton: .cancel())
        case .response214:
            return Alert(title: Text("You have not scanned the location for this fault report"), dismissButton: .default(Text("Okay"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        case .responseEquip200:
            return Alert(title: Text("Equip scan successfull"), dismissButton: .default(Text("Okay!"), action: {
                showEquipButton = false
                showUpdateButton = true
                showRequestPauseButton = true
            }))
        case .closeFRIfRequestPaused:
            return Alert(title: Text("Request for pause sent"), dismissButton: .default(Text("Okay!"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        case .closeFrAfterUpdate:
            return Alert(title: Text("Fault Report Updated"), dismissButton: .default(Text("Okay!"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        case .response215:
            return Alert(title: Text("Equipment scanned is not of the viewed fault report"), dismissButton: .cancel())
        case .response216:
            return Alert(title: Text("No Fault Reports found on this code"), dismissButton: .default(Text("Okay"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        case .sameStatusForUpdateAlert:
            return Alert(title: Text("Updating with \"\(currentStatus)\" status"),
                         message: Text("Do you wish to update the FR with \"\(currentStatus)\" status?"),
                         primaryButton: .default(Text("Okay!"), action: {
                                                    updateFaultReportFunc(updateFaultReportRequest: updateFaultReportRequest)}),
                         secondaryButton: .cancel())
        case .uploadQuotationAlert:
            return Alert(title: Text("Upload Qoutation"), message: Text("Upload Quotation for further action!"),
                         dismissButton: .default(Text("Okay!"), action: {
                            self.openQuotationSheet = true
                         }))
        case .none:
            return Alert(title: Text("test"))
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
                self.alertId = AlertId(id: .closeFrAfterUpdate)
                if let updateFrResponse = try? JSONDecoder().decode(CurrentFrResponse.self, from: data!){
                    DispatchQueue.main.async {
                        print(updateFrResponse)
                        
                    }
                }else{
                    print("not working")
                }
                
            } else {
                print("Error code: \(response.statusCode)")
            }
        }
        isLoading = false
        dataTask.resume()
        
        
    }
    
    func enableDisableButtons(currentFrResponse: CurrentFrResponse){
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
                }else if currentFrResponse.editable! == true && currentFrResponse.status! == CommonStrings().statusOpen && currentFrResponse.equipment != nil{
                    showEquipButton = true
                    showLocationButton = false
                }else if currentFrResponse.editable! == true && currentFrResponse.status! == CommonStrings().statusOpen && currentFrResponse.equipment == nil{
                    showEquipButton = false
                    showLocationButton = false
                    showUpdateButton = true
                }else if currentFrResponse.editable! == true && currentFrResponse.status! == CommonStrings().statusPause &&
                            currentFrResponse.eotType == CommonStrings().eotTypeGreaterActual{
                    self.alertId = AlertId(id: .uploadQuotationAlert)
                }
                else if currentFrResponse.editable! == false && currentFrResponse.status! == CommonStrings().statusPause{
                    showLocationButton = true
                }else if currentFrResponse.editable! == true && currentFrResponse.status! == CommonStrings().statusPause {
                    showLocationButton = false
                    showUpdateButton = true
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




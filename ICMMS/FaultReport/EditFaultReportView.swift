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
    @State var successBoolQuotation = false
    @State var openPurchaseSheet = false
    @State var successBoolPurchase = false
    @State private var activeSheet: EditFaultActiveSheet?
    @State var acceptedSuccessBool: Bool = false
    @State var equipmentScanBool = false
    @State var showCloseButtonBool = false
    @State var quotationAccepted = false
    @State var quotationRejected = false
    
    var body: some View {
        
        let updateFaultReportRequest : UpdateFaultRequest = UpdateFaultRequest(acknowledgerCode: currentFrResponse.acknowledgerCode, frId: currentFrResponse.frId, requestorName: currentFrResponse.requestorName, requestorContactNo: currentFrResponse.requestorContactNo, locationDesc: currentFrResponse.locationDesc, faultCategoryDesc: currentFrResponse.faultCategoryDesc, building: currentFrResponse.building, location: currentFrResponse.location, department: currentFrResponse.department, faultCategory: currentFrResponse.faultCategory, priority: currentFrResponse.priority, maintGrp: currentFrResponse.maintGrp, division: currentFrResponse.division, observation: observationString, diagnosis: "", actionTaken: actionTakenString, status: pickerItem, remarks: remarksList, attendedBy: currentFrResponse.attendedBy, eotTime: currentFrResponse.eotTime, eotType: currentFrResponse.eotType, activationTime: currentFrResponse.activationTime,arrivalTime: currentFrResponse.arrivalTime, restartTime: currentFrResponse.restartTime, responseTime: currentFrResponse.responseTime, downTime: currentFrResponse.downTime, pauseTime: currentFrResponse.pauseTime, completionTime: currentFrResponse.completionTime, acknowledgementTime: currentFrResponse.acknowledgementTime, reportedDate: currentFrResponse.reportedDate)
        
        
        VStack{
            if frIsLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(20)
                    .onAppear(){
                        getCurrentFaultReport(frId: frId)
                    }
            }else{
                
                ZStack{
                    ScrollView {
                        VStack{
                            //general items. Not editable
                            GeneralItemsFaultReport(frId: frId, currentFrResponse: currentFrResponse,
                                                    observationString: $observationString, actionTakenString: $actionTakenString)
                                .sheet(item: $activeSheet) { item in
                                    switch item {
                                    case .upQuoSheetCase:
                                        UploadQuotationView(frId: frId, openQuotationSheet: $openQuotationSheet, successBoolQuotation: $successBoolQuotation
                                                            , quotationAccepted: $quotationAccepted, quotationRejected: $quotationRejected, viewOpenedFrom: CommonStrings().editFaultReportActivity)
                                    case .second:
                                        //SecondView()
                                        Text("sec")
                                    }
                                }
                            
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
                                            EquipScanView(showScanSheet: $showScanSheet, QRValue: $QRValue,
                                                          frId: currentFrResponse.frId!, responseCode: $responseCode)
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
                                        .sheet(isPresented: $acceptSheetBool,onDismiss: {
                                            if acceptedSuccessBool  {
                                                self.alertId = AlertId(id: .acceptSheetBoolCase)
                                            }
                                        }, content: {
                                            AcceptPauseSheet(acceptRejectModel: acceptRejectModelFunc(), acceptSheetBool: $acceptSheetBool,
                                                             acceptedSuccessBool: $acceptedSuccessBool)
                                        })
                                        
                                        
                                        ZStack{
                                            if isLoading{
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                                    .padding()
                                            }else{
                                                Button(action: {
                                                    acceptRejectCall()
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
                                        
                                        
                                        if showCloseButtonBool{
                                            ZStack{
                                                if isLoading{
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle())
                                                        .padding()
                                                }else{
                                                    Button {
                                                        if remarksList.count > currentFrResponse.remarks!.count {
                                                            closeFRCall()
                                                        }else{
                                                            self.alertId = AlertId(id: .remarksListLessThanOne)
                                                        }
                                                    } label: {
                                                        HStack{
                                                            Spacer()
                                                            Text("Close Fault Report")
                                                            Spacer()
                                                        }
                                                    }
                                                    .padding()
                                                    .background(Color("Indeco_blue"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                                }
                                            }.padding()
                                        }
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
                                                        }else{
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
                                                    if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech{
                                                        if picker == CommonStrings().statusOpen {
                                                            showRequestPauseButton = true
                                                        }else if picker == CommonStrings().statusCompleted{
                                                            showRequestPauseButton = false
                                                        }
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
                                    return createAlert(alertId: alertId, updateFaultReportRequest: updateFaultReportRequest,
                                                       currentStatus: currentFrResponse.status!)
                                }
                            }
                            
                        }.padding(.top, 20)
                    }
                    
                    
                    ZStack(alignment: .bottomTrailing) {
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        FloatingMenuPdf(moreIcon: "newquote", purchaseImage: "quote_p", quoteImage: "quote_q", frId: frId,
                                        successBoolQuotation: $successBoolQuotation, openQuotationSheet: $openQuotationSheet,
                                        openPurchaseSheet: $openPurchaseSheet, successBoolPurchase: $successBoolPurchase,
                                        currentFrResponse: currentFrResponse, showUpdateButton: showUpdateButton,
                                        quotationAccepted: $quotationAccepted, quotationRejected: $quotationRejected)
                            .padding()
                    }
                    
                    ZStack(alignment: .bottomLeading) {
                        
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        FloatingMenuImages(moreIcon: "newquote", purchaseImage: "quote_p", quoteImage: "quote_q", frId: frId,
                                           successBeforeImageBool: $successBoolQuotation, openBeforeImageSheetBool: $openQuotationSheet,
                                           openAfterImageSheetBool: $openPurchaseSheet, successBeforeImageSheetBool: $successBoolPurchase,
                                           currentFrResponse: currentFrResponse, showUpdateButton: showUpdateButton)
                            .padding()
                    }
                    
                    
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
                
                guard let _ = data else { return }
                DispatchQueue.main.async {
                    do {
                        let frResponseOnSearch = try JSONDecoder().decode(CurrentFrResponse.self, from: data!)
                        self.currentFrResponse = frResponseOnSearch
                        print(currentFrResponse)
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
            frIsLoading = false
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
            equipmentScanBool = true
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
                if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech &&
                    currentFrResponse.status == CommonStrings().statusPause{
                    showRequestPauseButton = false
                }
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
                            activeSheet = .upQuoSheetCase
                         }))
        case .uploadPurchaseOrder:
            return Alert(title: Text("Upload Purchase order for further action"), dismissButton: .default(Text("Okay!")))
        case .cantTakeActionTillQuotationAcceptedAlert:
            return Alert(title: Text("Can't take action till quotation gets accepted!"), dismissButton: .default(Text("Okay")))
        case .pauseRequestRejectedCase:
            return
                Alert(title: Text("Pause request rejected"), dismissButton: .default(Text("Okay"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
        case .acceptSheetBoolCase:
            return Alert(title: Text("Pause Accepted"), dismissButton: .default(Text("Okay!"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
            
        case .remarksListLessThanOne:
            return Alert(title: Text("Add remarks"), message: Text("Please add atleast one remark before closing Fault Report."), dismissButton: .cancel())
        }
    }
    
    func acceptRejectCall()  {
        isLoading = true
        
        let acceptRejectModel = AcceptRejectModel(frId: frId,
                                                  observation: observationString,
                                                  actionTaken: actionTakenString,
                                                  // fmmDoc: nil
                                                  remarks: remarksList)
        
        let encodedBody = try? JSONEncoder().encode(acceptRejectModel)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/pauserequest/reject") else {return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = encodedBody
        
        
        print(urlRequest)
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
                self.alertId = AlertId(id: .pauseRequestRejectedCase)
            }else{
                print("Error: \(response.statusCode). There was an error")
            }
            
            isLoading = false
        }
        dataTask.resume()
        
        
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
                    self.alertId = AlertId(id: .closeFrAfterUpdate)
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
            statusPickerList.append(CommonStrings().statusCompleted)
            if currentFrResponse.status != nil{
                if currentFrResponse.status == CommonStrings().statusOpen{
                    if currentFrResponse.editable == false {
                        showLocationButton = true
                        showUpdateButton = false
                        showEquipButton = false
                    }else{
                        if currentFrResponse.equipment == nil{
                            showUpdateButton = true
                            showLocationButton = false
                            showEquipButton = false
                        }else{
                            showEquipButton = true
                            showLocationButton = false
                            showUpdateButton = false
                        }
                    }
                }else if currentFrResponse.status == CommonStrings().statusPause{
                    showRequestPauseButton = false
                    showAcceptReject = false
                    
                    if currentFrResponse.editable == false{
                        showLocationButton = true
                        showUpdateButton = false
                        showEquipButton = false
                    }else{
                        
                        if currentFrResponse.equipment == nil{
                            showUpdateButton = true
                            showLocationButton = false
                            showEquipButton = false
                        }else{
                            if currentFrResponse.eotType == CommonStrings().eotTypeGreaterActual {
                                if currentFrResponse.quotationStatus == CommonStrings().quotationStatusAccepted{
                                    if currentFrResponse.purchaseOrder == nil {
                                        self.alertId = AlertId(id: .uploadPurchaseOrder)
                                    }else if currentFrResponse.purchaseOrder != nil {
                                        showUpdateButton = false
                                        showLocationButton = false
                                        showEquipButton = true
                                    }
                                }else if currentFrResponse.quotationStatus == CommonStrings().quotationStatusRejected ||
                                            currentFrResponse.quotationStatus == nil{
                                    self.alertId = AlertId(id: .uploadQuotationAlert)
                                }else if currentFrResponse.quotationStatus == CommonStrings().quotationStatusUploaded{
                                    self.alertId = AlertId(id: .cantTakeActionTillQuotationAcceptedAlert)
                                }else{
                                    showUpdateButton = true
                                    showLocationButton = false
                                    showEquipButton = false
                                }
                            }else if currentFrResponse.eotType == CommonStrings().eotTypeLesserActual{
                                showUpdateButton = false
                                showLocationButton = false
                                showEquipButton = true
                            }
                        }
                    }
                    
                    
                }else if currentFrResponse.status == CommonStrings().statusCompleted &&
                            currentFrResponse.status == CommonStrings().statusClosed &&
                            currentFrResponse.status == CommonStrings().statusPauseRequested
                {
                    showEquipButton = false
                    showUpdateButton = false
                    showLocationButton = false
                    showRequestPauseButton = false
                    showAcceptReject = false
                }
                
            }
            
            
        } else if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameManag {
            statusPickerList.append("Open")
            statusPickerList.append("Closed")
            statusPickerList.append("Completed")
            
            if currentFrResponse.status != nil{
                
                if currentFrResponse.status! == CommonStrings().statusPause{
                    showUpdateButton = false
                    showAcceptReject = false
                }else if currentFrResponse.status! == CommonStrings().statusPauseRequested{
                    showAcceptReject = true
                    showUpdateButton = false
                    if currentFrResponse.eotType == CommonStrings().eotTypeGreaterActual{
                        showCloseButtonBool = true
                    }
                }else if currentFrResponse.status! == CommonStrings().statusCompleted {
                    showUpdateButton = true
                }else if currentFrResponse.status! == CommonStrings().statusClosed ||
                            currentFrResponse.status! == CommonStrings().statusOpen{
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
    
    
    func closeFRCall() {
        
        isLoading = true
        
        let body = CloseFaultReport(remarks: remarksList, frId: currentFrResponse.frId, status: "Closed", username: UserDefaults.standard.string(forKey: "username"), building: currentFrResponse.building, location: currentFrResponse.location, attendedBy: currentFrResponse.attendedBy)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/closefault") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = try? JSONEncoder().encode(body)
        print(urlRequest)
        
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
                    self.alertId = AlertId(id: .closeFrAfterUpdate)
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
    
}


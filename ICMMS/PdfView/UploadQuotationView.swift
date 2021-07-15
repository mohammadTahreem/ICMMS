//
//  UploadQuotationView.swift
//  ICMMS
//
//  Created by Tahreem on 14/06/21.
//

import SwiftUI
import PDFKit
import WebKit
import AVFoundation

struct UploadQuotationView: View {
    
    @State var frId: String
    @State var docSheet = false
    @State var pdfView = PDFKitRepresentedView(Data())
    @State var data = Data()
    @State var urlRequest = URLRequest(url: Bundle.main.url(forResource: "pdfback", withExtension: "png")!)
    @State var showUploadButton = false
    @State var showDownloadButton = false
    @State var fileURL: URL = Bundle.main.url(forResource: "pdfback", withExtension: "png")!
    @State var fileData: Data = Data()
    @Binding var openQuotationSheet: Bool
    @Binding var successBoolQuotation: Bool
    @EnvironmentObject var settings: UserSettings
    @State var remarksField: String = ""
    @State var showAcceptReject: Bool = false
    @Binding var quotationAccepted: Bool
    @Binding var quotationRejected: Bool
    @State var isLoadingRejected = false
    @State var isLoadingAccepted = false
    var currentFrResponse: CurrentFrResponse
    @State var quotationTitle = ""
    @Environment(\.presentationMode) var presentationMode
    @State var downloadSuccessBool = false

    
    @State var viewOpenedFrom: String
    
    var body: some View {
        
        let webView = WebView(request: urlRequest)
        VStack{
            Text("\(currentFrResponse.frId ?? "FR") Quotation" ).font(.body).padding()
            VStack{
                
                webView
                    .onAppear(){
                        
                        if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech && viewOpenedFrom == CommonStrings().editFaultReportActivity{
                            quotationTitle = "Quotation Upload"
                            if currentFrResponse.status! == CommonStrings().statusPause {
                                showUploadButton = true
                            }
                        }else{
                            quotationTitle = "Quotation"
                        }
                        
                        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/quotation/\(frId)") else {return}
                        var urlRequest1 = URLRequest(url: url)
                        urlRequest1.httpMethod = "GET"
                        urlRequest1.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        urlRequest1.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
                        urlRequest1.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
                        urlRequest1.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
                    
                    let dataTask = URLSession.shared.dataTask(with: urlRequest1) { (data, response, error) in
                        if let error = error {
                            print("Request error: ", error)
                            return
                        }
                        
                        guard let response = response as? HTTPURLResponse else {
                            print("response error: \(String(describing: error))")
                            return
                        }
                        
                        if response.statusCode == 200 {
                            self.urlRequest = urlRequest1
                            
                            
                            if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech{
                                if viewOpenedFrom == CommonStrings().editFaultReportActivity && currentFrResponse.status == CommonStrings().statusPause {
                                    showUploadButton = true
                                }else if viewOpenedFrom == CommonStrings().searchQuotation {
                                    showUploadButton = true
                                }
                            }else if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameManag &&
                                        self.urlRequest != URLRequest(url: Bundle.main.url(forResource: "pdfback", withExtension: "png")!){
                                showDownloadButton = true
                                if viewOpenedFrom == CommonStrings().editFaultReportActivity && currentFrResponse.status == CommonStrings().statusPause {
                                    showAcceptReject = true
                                }else{
                                    showAcceptReject = true
                                }
                            }
                            
                        }else{
                            print("Error: \(response.statusCode). There was an error")
                        }
                    }
                    dataTask.resume()
                }
                .cornerRadius(10)
                .padding()
                .shadow(radius: 10)
            
            
            HStack{
                if showUploadButton{
                    Button("Upload Document"){
                        docSheet.toggle()
                    }
                    .alert(isPresented: $successBoolQuotation, content: {
                        Alert(title: Text("Success"), message: Text("Quotation is uploaded"), dismissButton: .default(Text("Okay"), action: {
                            openQuotationSheet = false
                        }))
                    })
                    
                    .sheet(isPresented: $docSheet) {
                        DocumentPicker(fileContent: $fileURL, fileData: $fileData)
                            .onDisappear(){
                                if fileURL != Bundle.main.url(forResource: "pdfback", withExtension: "png")! {
                                    urlRequest = URLRequest(url: fileURL)
                                    let fileStream:String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
                                    uploadToServer(fileStream: fileStream)
                                }
                            }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Indeco_blue"))
                    .cornerRadius(10)
                }
                
                if showDownloadButton {
                    Button("Download"){
                        downloadAndView(fileName: "Quotation \(frId)")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Indeco_blue"))
                    .cornerRadius(10)
                    .alert(isPresented: $downloadSuccessBool) {
                        Alert(title: Text("Downloaded Successfully!"), dismissButton: .default(Text("Okay")))
                    }
                }
            }
            .padding()
        }
            
            if showAcceptReject{
                VStack{
                    TextField("Remarks", text: $remarksField)
                        .padding()
                        .background(Color("light_gray"))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    
                    HStack{
                        
                        if isLoadingAccepted{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }else{
                            Button(action: {
                                quotationAcceptReject(status: CommonStrings().quotationStatusAccepted)
                            }, label: {
                                Text(CommonStrings().quotationStatusAccepted)
                            })
                            .padding()
                            .background(Color("Indeco_blue"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .alert(isPresented: $quotationAccepted, content: {
                                Alert(title: Text("Quotation Accepted"), dismissButton: .default(Text("Okay"), action: {
                                    if viewOpenedFrom == CommonStrings().editFaultReportActivity{
                                        openQuotationSheet = false
                                    }else{
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                    
                                }))
                            })
                        }
                        if isLoadingRejected{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }else{
                            Button(action: {
                                quotationAcceptReject(status: CommonStrings().quotationStatusRejected)
                            }, label: {
                                Text(CommonStrings().quotationStatusRejected)
                            })
                            .padding()
                            .background(Color("Indeco_blue"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .alert(isPresented: $quotationRejected, content: {
                                Alert(title: Text("Quotation Rejected"), dismissButton: .default(Text("Okay!"), action: {
                                    openQuotationSheet = false
                                }))
                            })
                        }
                    }
                    .padding()
                    .padding(.bottom, 50)
                }
                .padding()
            }
        }
        .navigationBarTitle(quotationTitle)
        .navigationBarItems(trailing: Logout(workspaceViewBool: true, viewFrom: "").environmentObject(settings))
    }
    
    private func uploadToServer(fileStream: String)  {
        
        let body = UploadQuotationModel(id: frId, data: fileStream)
        let encodedBody = try? JSONEncoder().encode(body)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/quotationUpload") else {return}
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
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                return
            }
            
            if response.statusCode == 200 {
                successBoolQuotation = true
            }else{
                print("Error: \(response.statusCode). There was an error")
            }
        }
        dataTask.resume()
        
    }
    
    func downloadAndView(fileName:String) {
        
        downloadSuccessBool = true
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
                
                if let pdfData = data {
                    let pathURL = FileManager.default.urls(for: .documentDirectory,
                                                           in: .userDomainMask)[0].appendingPathComponent("\(fileName).pdf")
                    DispatchQueue.main.async {
                        do {
                            try pdfData.write(to: pathURL, options: .completeFileProtection)
                            
                            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                            let documentsDirectory = paths[0]
                            print("The path is: \(documentsDirectory)")
                            
                        } catch {
                            print("Error while writting")
                        }
                    }
                    
                    print("success")
                    //pdfView = PDFKitRepresentedView(pdfData)
                    self.data = pdfData
                }
                
                
            }else{
                print("Error: \(response.statusCode). There was an error")
            }
            downloadSuccessBool = false
        }
        dataTask.resume()
    }
    
    func quotationAcceptReject(status: String) {
        
        if status == CommonStrings().quotationStatusAccepted{
            isLoadingAccepted = true
        }else if status == CommonStrings().quotationStatusRejected{
            isLoadingRejected = true
        }
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/quotation/status") else {return}
        
        let body = AcceptRejectQuotationModel(frId: frId, quotationStatus: status, remarks: [remarksField])
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = try? JSONEncoder().encode(body)
        
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
                if status == CommonStrings().quotationStatusAccepted{
                    quotationAccepted = true
                }else if status == CommonStrings().quotationStatusRejected{
                    quotationRejected = true
                }
                
            }else{
                print("Error: \(response.statusCode). There was an error")
            }
            isLoadingAccepted = false
            isLoadingRejected = false
        }
        dataTask.resume()
    }
    
    
}

struct UploadQuotationView_Previews: PreviewProvider {
    
    
    
    static var previews: some View {
            UploadQuotationView(frId: "FR-ID", openQuotationSheet: .constant(true),
                                successBoolQuotation: .constant(false),
                                quotationAccepted: .constant(false), quotationRejected: .constant(false), currentFrResponse: CurrentFrResponse(), viewOpenedFrom: CommonStrings().searchQuotation) .environmentObject(UserSettings())
        }
}

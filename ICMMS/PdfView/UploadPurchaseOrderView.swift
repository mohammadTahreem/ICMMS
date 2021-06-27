//
//  UploadPurchaseOrderView.swift
//  ICMMS
//
//  Created by Tahreem on 16/06/21.
//

import SwiftUI

struct UploadPurchaseOrderView: View {
    @State var frId: String 
    @State var docSheet = false
    @State var pdfView = PDFKitRepresentedView(Data())
    @State var data = Data()
    @State var urlRequest = URLRequest(url: Bundle.main.url(forResource: "pdfback", withExtension: "png")!)
    @State var showUploadButton = false
    @State var showDownloadButton = false
    @State var fileURL: URL = Bundle.main.url(forResource: "pdfback", withExtension: "png")!
    @State var fileData: Data = Data()
    @State var successBool: Bool = false
    @EnvironmentObject var settings: UserSettings
    var currentFrResponse: CurrentFrResponse?
    var body: some View {
        
        let webView = WebView(request: urlRequest)
        VStack{
            
            webView
                .onAppear(){
                    
                    if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech{
                        if currentFrResponse?.status != nil{
                            if currentFrResponse?.status! != CommonStrings().statusClosed && currentFrResponse?.status! != CommonStrings().statusCompleted{
                                showUploadButton = true
                            }
                        }
                    }
                    
                    guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/purchaseOrder/\(frId)") else {return}
                    var urlRequestNew = URLRequest(url: url)
                    urlRequestNew.httpMethod = "GET"
                    urlRequestNew.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequestNew.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
                    urlRequestNew.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
                    urlRequestNew.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
                    
                    let dataTask = URLSession.shared.dataTask(with: urlRequestNew) { (data, response, error) in
                        if let error = error {
                            print("Request error: ", error)
                            return
                        }
                        
                        guard let response = response as? HTTPURLResponse else {
                            print("response error: \(String(describing: error))")
                            return
                        }
                        
                        if response.statusCode == 200 {
                            self.urlRequest = urlRequestNew
                            showUploadButton = false
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
                    .alert(isPresented: $successBool, content: {
                        Alert(title: Text("Success"), message: Text("Purchase Order is uploaded"), dismissButton: .cancel())
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
                        downloadAndView(fileName: "Purchase Order \(frId)")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Indeco_blue"))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarTitle("Upload Purchase Order")
        .navigationBarItems(trailing: Logout().environmentObject(settings))
    }
    
    private func uploadToServer(fileStream: String)  {
        
        let body = UploadQuotationModel(id: frId, data: fileStream)
        let encodedBody = try? JSONEncoder().encode(body)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/purchaseOrder") else {return}
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
                successBool = true
            }else{
                print("Error: \(response.statusCode). There was an error")
            }
        }
        dataTask.resume()
        
    }
    
    func downloadAndView(fileName:String) {
        
        
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
        }
        dataTask.resume()
        
        
        
        
    }
}

struct UploadPurchaseOrderView_Previews: PreviewProvider {
    static var previews: some View {
        UploadPurchaseOrderView(frId: "", currentFrResponse: CurrentFrResponse())
    }
}

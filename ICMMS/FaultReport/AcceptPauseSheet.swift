//
//  AcceptPauseSheet.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation
import SwiftUI


struct AcceptPauseSheet: View {
    @State var acceptRejectModel: AcceptRejectModel
    @Binding var acceptSheetIsPresented: Bool
    @State var urlRequest = URLRequest(url: Bundle.main.url(forResource: "pdfback", withExtension: "png")!)
    @State var docSheet = false
    @State var fileURL: URL = Bundle.main.url(forResource: "pdfback", withExtension: "png")!
    @State var fileData: Data = Data()
    @Binding var acceptedSuccessBool: Bool
    
    var body: some View {
        let webView = WebView(request: urlRequest)
        
        VStack{
            webView
                .padding()
                .alert(isPresented: $acceptedSuccessBool) {
                    Alert(title: Text("Accepted Successfully!"), dismissButton: .default(Text("Okay!"), action: {
                        acceptSheetIsPresented = false
                    }))
                }
            HStack{
                Button("Upload Authorizer document"){
                    docSheet.toggle()
                }
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
        }
    }
    
    private func uploadToServer(fileStream: String)  {
        
        acceptRejectModel = AcceptRejectModel(frId: acceptRejectModel.frId,
                                              observation: acceptRejectModel.observation,
                                              actionTaken: acceptRejectModel.actionTaken,
                                              fmmDocForAuthorize: "aksjhdkajs", // check this
                                              remarks: acceptRejectModel.remarks)
        
        let encodedBody = try? JSONEncoder().encode(acceptRejectModel)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/pauserequest/accept") else {return}
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
                acceptedSuccessBool = true
            }else{
                print("Error: \(response.statusCode). There was an error")
            }
        }
        dataTask.resume()
        
    }
}


//
//  MessagesSheet.swift
//  ICMMSAPP
//
//  Created by Mohammad Tahreem Qadri on 27/04/21.
//

import SwiftUI

struct MessagesSheet: View {
    
    @State var messages: [MessagesModel] = [MessagesModel()]
    @Binding var messageSheetBool: Bool
    @State var isLoading = true
    
    var body: some View {
        NavigationView{
            VStack{
                if isLoading{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .onAppear(){
                            getMessages()
                        }
                }else{
                    List(messages, id:\.self){ message in
                        NavigationLink(destination: ChatSheet(type: message.type ?? "", messageTitle: message.title ?? "")){
                            MessageCardView(message: message)
                                .padding()
                        }
                    }
                }
            }
            
            .navigationBarTitle("Messages")
        }
    }
    
    func getMessages() {
        isLoading = true
        guard let url = URL(string: "\(CommonStrings().apiURL)msg/") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
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
                
                if let messagesModel = try? JSONDecoder().decode([MessagesModel].self, from: data!){
                    DispatchQueue.main.async {
                        self.messages = messagesModel
                        print(messages)
                    }
                }
                
            } else {
                print("Error code: \(response.statusCode)")
            }
            isLoading = false
        }
        
        dataTask.resume()
    }
}

struct MessageCardView: View {
    
    @State var message: MessagesModel
    
    var body: some View {
        VStack{
            HStack{
                Text(message.title ?? "")
                    .foregroundColor(.black)
                    .font(.caption)
                    .bold()
                    
                Spacer()
                Text(GeneralMethods().convertTStringToString(isoDate: message.createdDate ?? "2020-08-08 12:32") )
                    .foregroundColor(Color("Indeco_blue"))
                    .font(.caption)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }.padding()
            
            Divider()
                .padding(.horizontal, 20)
            Text(message.text ?? "")
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(3)
                .padding()
        }
        .background(Color("light_gray"))
        .cornerRadius(8)
        .shadow(radius: 10)
    }
}

struct MessagesSheet_Previews: PreviewProvider {
    @State static var isShowing = false
    static var previews: some View {
        
        MessageCardView(message: MessagesModel(title: "Quotation Uploaded", text: "Purchase Order has been Uploaded for Fault Report Id : FR-DEMO-062021-00116 in building TOWER1 & location LEVEL1", createdDate: "2021-06-14T12:39:41", type: "Qoutation Uploaded", id: 123321))
        
//        MessagesSheet(messages: [MessagesModel(title: "Quotation Uploaded", text: "Purchase Order has been Uploaded for Fault Report Id : FR-DEMO-062021-00116 in building TOWER1 & location LEVEL1", createdDate: "2021-06-14T12:39:41", type: "Qoutation Uploaded", id: 123321)], messageSheetBool: .constant(true), isLoading: false)
    }
}

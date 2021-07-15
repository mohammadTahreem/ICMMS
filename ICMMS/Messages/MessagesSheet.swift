//
//  MessagesSheet.swift
//  ICMMSAPP
//
//  Created by Mohammad Tahreem Qadri on 27/04/21.
//

import SwiftUI

struct MessagesSheet: View {
    
    @State var messages: [MessagesModel] = [MessagesModel()]
    @State var messagesCountModel: MessageCountModel?
    @Binding var messageSheetBool: Bool
    @State var isLoading = true
    @EnvironmentObject var badges: MessageIconBadge
    @State var frId: String?
    @EnvironmentObject var settings: UserSettings
    @State var showFR: Bool = false
    @State var messageReadingBool : Bool = false
    @State var emptyAlert: Bool = false
    var body: some View {
        NavigationView{
            VStack { 
                if isLoading{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .onAppear(){
                            getMessages()
                        }
                }else{
                    ScrollView{
                        ForEach(messages, id:\.self){ message in
                            
                            NavigationLink(destination: EditFaultReportView(frId: frId ?? "", QRValue: "", viewFrom: CommonStrings().messagesView)
                                            .environmentObject(settings)
                                            .environmentObject(badges)
                                           , isActive: $showFR)
                            {
                                MessageCardView(message: message, seen: message.seen!)
                                    .padding()
                                    .onTapGesture {
                                        updateNotification(id: message.id!)
                                    }
                            }
                        }
                    }
                }
            }.alert(isPresented: $emptyAlert) {
                Alert(title: Text("No messages available!"), dismissButton: .cancel())
            }
            
            .navigationBarTitle("Messages")
        }
    }
    
    func getMessages() {
        
        self.badges.items = 0
        self.messages = []
        
        isLoading = true
        guard let url = URL(string: "\(CommonStrings().apiURL)msg/messages") else {return}
        
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
                
                if let messagesCountModel = try? JSONDecoder().decode(MessageCountModel.self, from: data!){
                    DispatchQueue.main.async {
                        self.messagesCountModel = messagesCountModel
                        messages = messagesCountModel.messages
                        self.badges.items = messagesCountModel.count
                        if self.messages.isEmpty {
                            emptyAlert = true
                        }
                        print(messagesCountModel)
                    }
                }
            } else {
                print("Error code: \(response.statusCode)")
            }
            isLoading = false
        }
        
        dataTask.resume()
    }
    
    
    func updateNotification(id: Int) {
        
        guard let url = URL(string: "\(CommonStrings().apiURL)msg/\(id)") else {return}
        
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
            
            guard let response = response as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                return
            }
            
            if response.statusCode == 200 {
                
                guard let _ = data else { return }
                
                if let messageReadResponse = try? JSONDecoder().decode(MessagesModel.self, from: data!){
                    DispatchQueue.main.async {
                        self.frId = messageReadResponse.extras?.id
                        getMessages()
                        if !frId!.isEmpty {
                            showFR = true
                        }
                        print(messageReadResponse)
                    }
                }
            } else {
                print("Error code: \(response.statusCode)")
            }
        }
        
        dataTask.resume()
    }
    
}

struct MessageCardView: View {
    
    var message: MessagesModel
    var seen: Bool
    
    var body: some View {
        
       
            VStack{
                HStack{
                    Text(message.title ?? "")
                        .foregroundColor(seen ? .black : .red)
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
        
//        MessageCardView(message: MessagesModel(title: "Quotation Uploaded",
//                                               text: "Purchase Order has been & location LEVEL1",
//                                               createdDate: "2021-06-14T12:39:41", type: "Qoutation Uploaded", id: 123321),
//                        seen: true)
       
        MessagesSheet(messages: [MessagesModel(title: "askfhakjsgf", text: "ajshgdjagsfjg", createdDate: "ajshgjas", type: "asjhdg", id: 112, seen: false, extras: Extras())], messageSheetBool: .constant(true))
            .environmentObject(UserSettings())
            .environmentObject(MessageIconBadge())
    }
}

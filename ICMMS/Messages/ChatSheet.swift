//
//  ChatSheet.swift
//  ICMMS
//
//  Created by Mohammad Tahreem Qadri on 28/04/21.
//

import SwiftUI

struct ChatSheet: View {
    
    @State var chats: [MessagesModel] = [MessagesModel()]
    @State var type: String?
    @State var messageTitle: String?
    @State var isLoading = false
    var body: some View {
        VStack{
            if isLoading{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }else{
                List(chats, id:\.self){ chat in
                    MessageCardView(message: chat)
                        .padding()
                }
            }
        }.navigationBarTitle("\(messageTitle!)")
        .onAppear(){
            if (type != nil){
                getChats()
            }
        }
    }
    func getChats() {
        isLoading = true
        guard let url = URL(string: "\(CommonStrings().apiURL)msg/type?type=\(type!)") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
                
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
                        self.chats = messagesModel
                        print(chats)
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

struct ChatSheet_Previews: PreviewProvider {
    static var previews: some View {
        ChatSheet()
    }
}

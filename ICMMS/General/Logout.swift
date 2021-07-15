//
//  Logout.swift
//  ICMMS
//
//  Created by Tahreem on 02/06/21.
//

import Foundation
import SwiftUI

struct Logout: View {
    let token = UserDefaults.standard.string(forKey: "token")
    let deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
    @EnvironmentObject var settings: UserSettings
    @State var messageSheetBool: Bool = false
    @State var errorPresented: Bool = false
    @State var logoutLoading: Bool = false
    @State var workspaceViewBool: Bool
    @EnvironmentObject var order: MessageIconBadge
    @State private var badgeCount: Int = 1
    private var badgePosition: CGFloat = 2
    @State var viewSource: String
    
    var body: some View{
        if viewSource != CommonStrings().messagesView{
        HStack{
            
            if workspaceViewBool {
            ZStack(alignment: .topTrailing){
                
                Image("messages")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .onTapGesture {
                        messageSheetBool = true
                    }.sheet(isPresented: $messageSheetBool, content: {
                        MessagesSheet(messageSheetBool: $messageSheetBool)
                            .environmentObject(settings)
                            .environmentObject(order)
                    })
                if self.order.items != 0 {
                    ZStack {
                        Circle()
                            .foregroundColor(.red)

                        Text("\(self.order.items)")
                            .foregroundColor(.white)
                            .font(Font.system(size: 12))
                    }
                    .frame(width: 15, height: 15)
                }
            }
            }
            if logoutLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }else{
                Button(
                    action: {logout()},
                    label: {Image("logout").resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 45, height: 45)
                    }
                ).alert(isPresented: $errorPresented, content: {
                    Alert(title: Text("Error"), message: Text("There was an error:"), dismissButton: .cancel())
                })
            }
            
        }
        }else{
            EmptyView()
        }
    }
    
    
    
    func logout()  {
        logoutLoading = true
        let currentUrl = CommonStrings().apiURL
        
        let urlString = "\(currentUrl)logout?&deviceToken=\(UserDefaults.standard.string(forKey: "deviceToken")!)"
        guard let url = URL(string: urlString) else {return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        
        print(urlRequest)
        
        URLSession.shared.dataTask(with: urlRequest){data, responseCode, error in
            
            if let error = error {print("Error received: \(error)")
                return
            }
            
            guard let response = responseCode as? HTTPURLResponse else{
                print("response error: \(String(describing: error))")
                return
            }
            
            if response.statusCode == 200 || response.statusCode == 401 {
                
                DispatchQueue.main.async {
                    _ = try? JSONSerialization.jsonObject(with: data!, options: [])
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    UserDefaults.standard.setValue(deviceToken, forKey: "deviceToken")
                    UserDefaults.standard.synchronize()
                    self.settings.loggedIn = false
                }
                
            }else{
                print("The error is: \(String(describing: error))")
                errorPresented.toggle()
            }
            logoutLoading = false
        }.resume()
    }
    
    public init(workspaceViewBool: Bool, viewFrom: String) {
        self.workspaceViewBool = workspaceViewBool
        self.viewSource = viewFrom
    }

}


struct LogoutPreview: PreviewProvider {
    static var previews: some View {
        Logout(workspaceViewBool: true, viewFrom: "").environmentObject(UserSettings()).environmentObject(MessageIconBadge())
    }
}


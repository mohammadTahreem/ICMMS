//
//  LoginView.swift
//  ICMMS
//
//  Created by Tahreem on 02/06/21.
//

import SwiftUI

struct LoginView: View {
    
    @State var username = ""
    @State var password = ""
    @State var data : LoginResponse = LoginResponse()
    @State private var showingAlert = false
    @State private var buttonClicked = false
    @State var errorCode: String = ""
    @EnvironmentObject var settings: UserSettings
    @State var deviceToken : String = ""
    
    
    var body: some View {
        
        let params: [String: Any] = [
            "username": username,
            "password": password,
            "deviceToken": UserDefaults.standard.string(forKey: "deviceToken") ?? "no data"
        ]
        VStack(){
            
            Spacer()
            
            VStack{
                Image("icmmslogo")
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                
                
                HStack{
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                        .padding()
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                }
                
                .background(Color.white)
                .cornerRadius(8)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                
                HStack{
                    Image(systemName: "lock")
                        .foregroundColor(.black)
                        .padding()
                    SecureField("Password", text: $password)
                        .padding()
                }
                .background(Color.white)
                .cornerRadius(8)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                
                
                ZStack{
                    
                    if buttonClicked {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(20)
                    } else {
                        Button(action: {
                            self.getData(params: params)
                        }, label: {
                            Text("Login").foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color("Indeco_blue"))
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                                .opacity(1)
                        })
                        .disabled(username.isEmpty || password.isEmpty)
                        .alert(isPresented: $showingAlert, content: {
                            Alert(title: Text("Error"), message: Text("Please check the username and password."), dismissButton: .default(Text("Okay!")))
                        })
                    }
                }
            }
            
            .background(Color.white)
            .cornerRadius(12)
            .opacity(0.8)
            .padding()
            
            Spacer()
        }.background( Image("indecoback")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
        ).edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
    
    func getData(params: [String:Any])  {
        
        buttonClicked = true
        print(params)
        let body = try? JSONSerialization.data(withJSONObject: params)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)authenticate") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                showingAlert = true
                buttonClicked = false
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                showingAlert = true
                buttonClicked = false
                print("response error: \(String(describing: error))")
                return
            }
            
            if response.statusCode == 200 {
                
                guard let _ = data else { return }
                DispatchQueue.main.async {
                    do {
                        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data!)
                        UserDefaults.standard.set(loginResponse.token, forKey: "token")
                        UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
                        UserDefaults.standard.set(loginResponse.role, forKey: "role")
                        UserDefaults.standard.set(loginResponse.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        print(loginResponse)
                        self.settings.loggedIn = true
                    } catch let error {
                        print("Error decoding: ", error)
                        showingAlert = true
                    }
                }
            } else {
                print("The last print statement: \(data!)")
                print("Error code: \(response.statusCode)")
                self.errorCode = "\(response.statusCode)"
                showingAlert = true
            }
            buttonClicked = false
        }
        
        dataTask.resume()
    }
}

struct LoginViewPre: PreviewProvider {
    static var previews: some View{
        LoginView(deviceToken: "demo")
    }
}

struct MainScreen: View{
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View{
        
        if settings.loggedIn {
            WorkspaceView().environmentObject(settings)
        }else {
            if UserDefaults.standard.bool(forKey: "loggedIn") == true {
                WorkspaceView().environmentObject(settings)
            }else{
                LoginView().environmentObject(settings)
            }
        }
    }
    
}

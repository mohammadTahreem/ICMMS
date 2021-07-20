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
    @State var showForgetAlert : Bool = false
    @State var resetEmail: String = ""
    @State var deviceToken : String
    
    var body: some View {
        
        
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
                .sheet(isPresented: $showForgetAlert, content: {
                    ResetPasswordView(showForgetAlert: $showForgetAlert)
                })
                
                
                ZStack{
                    
                    if buttonClicked {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(20)
                    } else {
                        Button(action: {
                            self.getData()
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
                
                Button {
                    showForgetAlert = true
                } label: {
                    Text("Forget Password?")
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(12)
            .opacity(0.9)
            .padding()
            
            Spacer()
        }.background( Image("indecoback")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
        ).edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
    
    func getData()  {
        
        let params: [String: Any] = [
            "username": username,
            "password": password,
            "deviceToken": deviceToken
        ]
        
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
                        UserDefaults.standard.set(loginResponse.role, forKey: "role")
                        UserDefaults.standard.set(loginResponse.username, forKey: "username")
                        UserDefaults.standard.setValue(deviceToken, forKey: "deviceToken")
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
        LoginView(deviceToken: "")
    }
}

 struct MainScreen: View{
    @EnvironmentObject var isFrom : IsFromNotificationClass
    @EnvironmentObject var settings: UserSettings
    var frId = UserDefaults.standard.string(forKey: "frId")
    var workspace = UserDefaults.standard.string(forKey: "workspace")
    var view = UserDefaults.standard.string(forKey: "view")
    @State var showEditFr = UserDefaults.standard.string(forKey: "showEditFr")
    @State var deviceToken: String
    
    var body: some View{
        
        if settings.loggedIn {
            if !isFrom.isFromNotication {
                WorkspaceView().environmentObject(settings)
            }else if isFrom.isFromNotication {
                
                if UserDefaults.standard.string(forKey: "frId") != nil {
                    NavigationView{
                        EditFaultReportView(frId: UserDefaults.standard.string(forKey: "frId")!,QRValue: "" ,
                                            viewFrom: "Active")
                            .environmentObject(settings)
                    }
                }else{
                    WorkspaceView().environmentObject(settings)
                }
            }
        } else if !settings.loggedIn {
            if UserDefaults.standard.bool(forKey: "loggedIn") == true {
                
                if  !isFrom.isFromNotication {
                    WorkspaceView().environmentObject(settings)
                }else if  isFrom.isFromNotication && frId != nil {
                    NavigationView{
                        EditFaultReportView(frId: UserDefaults.standard.string(forKey: "frId")!,QRValue: "" ,
                                            viewFrom: "Active")
                            .environmentObject(settings)
                    }
                }
            }
            else if UserDefaults.standard.bool(forKey: "loggedIn") == false {
                if isFrom.isFromNotication {
                    LoginView(deviceToken: deviceToken).environmentObject(settings)
                }
                else if !isFrom.isFromNotication {
                    LoginView(deviceToken: deviceToken).environmentObject(settings)
                }
            }
        }
    }
 }

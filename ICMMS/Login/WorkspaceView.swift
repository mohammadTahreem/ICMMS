//
//  ContentView.swift
//  ICMMS
//
//  Created by Mohammad Tahreem Qadri on 01/06/21.
//

import SwiftUI

struct WorkspaceView: View {
    
    @State var workspaceResponse: [WorkspaceResponse] = []
    @State var progressViewBool: Bool = true
    @State private var loginAlert: Bool = false
    @State private var errorAlert: Bool = false
    @EnvironmentObject var settings: UserSettings
    @State var alertId: WorkspaceAlertId?
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView{
            if progressViewBool {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .alert(isPresented: $errorAlert, content: {
                        Alert(title: Text("Error"), message: Text("Please try again!"),
                              dismissButton: .cancel())
                    })
                    .onAppear(){
                        getWorkspaces()
                    }
            }else{
                List(workspaceResponse, id: \.self) { workspaceResponse in
                    ZStack{
                        Button("") {}
                            .alert(item: $alertId) { (alertId) -> Alert in
                                return createAlert(alertId: alertId)
                            }
                        NavigationLink(destination: DashboardView(workspace: workspaceResponse.workspaceId)){
                            WorkSpaceCardView(workspaceResponse: workspaceResponse)
                                .padding()
                        }
                    }
                }
                .padding()
                .alert(isPresented: $loginAlert, content: {
                    Alert(title: Text("Error"), message: Text("There was an error. Please try logging in again!"), dismissButton: .default(Text("Okay!")))
                })
                .navigationBarTitle("Workspaces", displayMode: .inline)
                .toolbar(){
                    ToolbarItem(placement: .navigationBarTrailing){
                        Logout().environmentObject(settings)
                    }
                }
            }
        }
    }
    
    private func createAlert(alertId: WorkspaceAlertId) -> Alert{
        switch alertId.id {
        
        case .responseTimeOut:
            return Alert(title: Text("Time Out Error"), dismissButton: .default(Text("Okay"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
    }
    func getWorkspaces()  {
        let currentUrl = CommonStrings().apiURL
        print(UserDefaults.standard.string(forKey: "token")!)
        guard let url = URL(string: "\(currentUrl)workspaces") else {return}
        print(url)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                self.alertId = WorkspaceAlertId(id: .responseTimeOut)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return
                print("response error: \(String(describing: error))")
            }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    do {
                        let workspaceResponse = try JSONDecoder().decode([WorkspaceResponse].self, from: data!)
                        self.workspaceResponse = workspaceResponse
                    } catch let error {
                        print("Error decoding: ", error)
                        errorAlert = true
                    }
                }
            }else if response.statusCode == 401 {
                print("Error: \(response.statusCode)")
                self.loginAlert = true
            }
            else{
                print("The last print statement: \(data!)")
                self.errorAlert = true
            }
            progressViewBool = false
        }
        
        dataTask.resume()
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View{
        WorkspaceView()
    }
}

struct WorkSpaceCardView: View {
    @State var workspaceResponse: WorkspaceResponse
    var body: some View{
        
        HStack{
            Spacer()
            VStack(){
                Text(workspaceResponse.workspaceId)
                Text(workspaceResponse.buildingDescription)
            }
            Spacer()
        }
        .padding()
        .background(Color("light_gray"))
        .foregroundColor(.black)
        .cornerRadius(8)
        .shadow(radius: 5)
        
    }
}


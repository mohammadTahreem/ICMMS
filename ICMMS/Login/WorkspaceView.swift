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
    @State var workspaceAlertId: WorkspaceAlertId?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var badges : MessageIconBadge

    var body: some View {
        NavigationView{
            VStack{
                if progressViewBool{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .onAppear(){
                            getWorkspaces()
                        }
                }else{
                    List(workspaceResponse, id: \.self) { workspaceResponse in
                        
                        NavigationLink(destination: DashboardView(workspace: workspaceResponse.workspaceId)){
                            WorkSpaceCardView(workspaceResponse: workspaceResponse)
                                .padding()
                        }
                    }.listStyle(PlainListStyle())
                    .alert(item: $workspaceAlertId) { alertId -> Alert in
                        return createAlert(alertId: alertId)}
                }
            }
            .navigationBarTitle("Workspaces", displayMode: .inline)
         //   .navigationBarItems(trailing: Text(UserDefaults.standard.string(forKey: "role") ?? "").foregroundColor(Color("Indeco_blue")))
            .navigationBarItems(trailing: Logout(workspaceViewBool: false, viewFrom: "").environmentObject(settings))
        }
    }
    
    private func createAlert(alertId: WorkspaceAlertId) -> Alert{
        switch alertId.id {
        
        case .responseTimeOut:
            return Alert(title: Text("Time Out Error"),message: Text("Please close the app and try again!"), dismissButton: .default(Text("Okay"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        case .errorAlert:
            return Alert(title: Text("Error"), message: Text("Please try again!"),
                         dismissButton: .cancel())
        case .loginAlert:
            return Alert(title: Text("Error"), message: Text("There was an error. Please try logging in again!"),
                         dismissButton: .default(Text("Logout!")))
        }
    }
    func getWorkspaces()  {
        let currentUrl = CommonStrings().apiURL
        guard let url = URL(string: "\(currentUrl)workspaces") else {return}
        print(url)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
                
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                self.workspaceAlertId = WorkspaceAlertId(id: .responseTimeOut)
                print("Request error: ", error)
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
                        self.workspaceAlertId = WorkspaceAlertId(id: .errorAlert)
                    }
                }
            }else if response.statusCode == 401 {
                print("Error: \(response.statusCode)")
                self.workspaceAlertId = WorkspaceAlertId(id: .loginAlert)
            }
            else{
                print("The last print statement: \(data!)")
                self.workspaceAlertId = WorkspaceAlertId(id: .errorAlert)
            }
            progressViewBool = false
        }
        
        dataTask.resume()
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View{
        WorkspaceView().environmentObject(UserSettings())
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


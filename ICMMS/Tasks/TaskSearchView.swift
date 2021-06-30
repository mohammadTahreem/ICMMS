//
//  TaskSearchView.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 15/03/21.
//

import SwiftUI

struct TaskSearchView: View {
    
    var userLoggedIn = UserDefaults.standard.string(forKey: "role")
    
    var body: some View {
        VStack{
            if (userLoggedIn == CommonStrings().usernameTech) {
                TaskSearchTechView()
            }else {
                TaskSearchManView()
            }
        }
        .navigationBarTitle("Search Tasks")
        
    }
}

struct TaskSearchTechView: View {
    @EnvironmentObject var settings: UserSettings

    var body : some View{
        TabView{
            SearchViewTask( activeInactive: "Active")
                .tabItem{
                    Text("Active")
                }
            SearchViewTask( activeInactive: "Inactive")
                .tabItem{
                    Text("InActive")
                }
        }
        .toolbar(){
            ToolbarItem(placement: .navigationBarTrailing){
                Logout().environmentObject(settings)
            }
        }
    }
}

struct TaskSearchManView: View {
    var body : some View{
        SearchViewTask(activeInactive: "InActive")
    }
}

struct SearchViewTask: View {
    
    @State var searchText: String = ""
    @State var activeInactive: String
    @State var taskSearchResponse : [TaskSearchResponse] = []
    @State private var isLoading = false
    var body: some View {
        
        VStack{
            TextField("Search Tasks",text: $searchText)
                .padding()
                .onChange(of: searchText, perform: {
                    newvalue in
                    getTaskReports(searchText: newvalue)
                })
                .background(Color("light_gray"))
                .foregroundColor(.black)
                .cornerRadius(8)
                .padding()
            if isLoading{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            Spacer()
            List (taskSearchResponse, id: \.self)  { taskSearchResponse in
                ZStack{
                    Button("") {}
                    NavigationLink(destination: PmTaskView(taskId: taskSearchResponse.taskId!)){
                        TaskSearchCardView(taskSearchResponse: taskSearchResponse)
                            .padding()
                            .background(Color("light_gray"))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding()
                    }
                }
            }
        }
    }
    func getTaskReports(searchText: String)  {
        isLoading = true
        let currentUrl = CommonStrings().apiURL
        
        let urlString = "\(currentUrl)task/search?query=\(searchText)&type=\(activeInactive)"
        
        guard let url = URL(string: urlString) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        URLSession.shared.dataTask(with: urlRequest){data, responseCode, error in
            
            if let taskSearchResponse = try? JSONDecoder().decode([TaskSearchResponse].self, from: data!){
                DispatchQueue.main.async {
                    self.taskSearchResponse = taskSearchResponse
                }
            }else{
                print("There was an error: \(error.debugDescription)")
            }
            isLoading = false
        }.resume()
    }
}

struct TaskSearchCardView: View {
    var taskSearchResponse: TaskSearchResponse
    
    
    var body: some View{
        VStack{
            HStack{
                if (taskSearchResponse.scheduleDate != nil){
                    Text(GeneralMethods().convertLongToString(isoDate: taskSearchResponse.scheduleDate!))
                        .font(.caption)
                }
                Spacer()
                if(taskSearchResponse.status != nil){
                    Text(taskSearchResponse.status!)
                        .font(.caption)
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color(red: 0.024, green: 0.329, blue: 0.645)/*@END_MENU_TOKEN@*/)
                }
            }
            Divider()
            VStack{
                if( taskSearchResponse.taskNumber != nil){
                    Text(taskSearchResponse.taskNumber!)
                        .font(.title)
                        .bold()
                }
                if(taskSearchResponse.equipmentName != nil){
                    Text(taskSearchResponse.equipmentName!)
                        .font(.caption)
                    
                }
            }
            Divider()
            HStack{
                if(taskSearchResponse.buildingName != nil){
                    Text(taskSearchResponse.buildingName!)
                        .font(.caption)
                }
                Spacer()
                if(taskSearchResponse.locationName != nil){
                    Text(taskSearchResponse.locationName!)
                        .font(.caption)
                }
            }
        }
    }
    
    
    
}


struct TaskSearchView_Previews : PreviewProvider {
    static var previews : some View{
        TaskSearchView()
    }
}
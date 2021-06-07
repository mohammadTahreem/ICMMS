//
//  SwiftUIView.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import SwiftUI


struct FaultSearchCardView: View {
    
    var searchFaultResponse : FaultSearchResponse
    var body: some View{
        VStack{
            HStack{
                if(searchFaultResponse.activationTime != nil){
                    Text(GeneralMethods().convertTStringToString(isoDate: searchFaultResponse.activationTime!))
                        .font(.caption)
                }
                Spacer()
                if(searchFaultResponse.status != nil){
                    Text(searchFaultResponse.status!)
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color(red: 0.024, green: 0.329, blue: 0.645)/*@END_MENU_TOKEN@*/)
                        .font(.caption)
                }
            }
            Divider()
            HStack{
                if(searchFaultResponse.frId != nil){
                    Text(searchFaultResponse.frId!)
                        .font(.headline)
                        .bold()
                }
            }
            Divider()
            HStack{
                if(searchFaultResponse.buildingName != nil){
                    Text(searchFaultResponse.buildingName!)
                        .font(.caption)
                }
                Spacer()
                if(searchFaultResponse.locationName != nil){
                    Text(searchFaultResponse.locationName!)
                        .font(.caption)
                }
            }
        }
        
    }
}


struct FaultSearchView: View {
    
    @State var searchText: String = ""
    @State var activeInactive: String
    @State var searchFaultResponse : [FaultSearchResponse] = []
    
    var body: some View {
        
        VStack{
            TextField("Search Fault Reports",text: $searchText)
                .onChange(of: searchText, perform: {
                    newvalue in
                    getFaultReports(searchText: newvalue)
                })
                .padding()
                .background(Color("light_gray"))
                .foregroundColor(.black)
                .cornerRadius(8)
                .padding()
            
            Spacer()
            
            List (searchFaultResponse, id: \.self)  { searchFaultResponse in
                ZStack{
                    Button("") {}
                    NavigationLink(destination: EditFaultReportView(frId: searchFaultResponse.frId!)){
                        FaultSearchCardView(searchFaultResponse: searchFaultResponse)
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
    func getFaultReports(searchText: String)  {
        let currentUrl = CommonStrings().apiURL
        
        let urlString = "\(currentUrl)faultreport/search?query=\(searchText)&type=\(activeInactive)"
        print(urlString)
        
        guard let url = URL(string: urlString) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        print(urlRequest)
        
        URLSession.shared.dataTask(with: urlRequest){data, responseCode, error in
            
            if let searchFaultResponse = try? JSONDecoder().decode([FaultSearchResponse].self, from: data!){
                DispatchQueue.main.async {
                    self.searchFaultResponse = searchFaultResponse
                }
            }else{
                print("There was an error: \(error.debugDescription)")
                
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let dictionary = json as? [String: Any] {
                    print("Error decoding: \(dictionary)")
                }
            }
            
        }.resume()
    }
}



struct SearchFaultReportView: View {
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        TabView{
            FaultSearchView( activeInactive: "Active")
                .tabItem{
                    Text("Active")
                }
            FaultSearchView( activeInactive: "Inactive")
                .tabItem{
                    Text("InActive")
                }
        }
        .toolbar(){
            ToolbarItem(placement: .navigationBarTrailing){
                Logout().environmentObject(settings)
            }
        }
        .navigationBarTitle("Search Fault Reports")
        
    }
}


struct SearchFRView_Preview: PreviewProvider {
    static var previews: some View {
        FaultSearchView( activeInactive: "Active")
    }
    
}
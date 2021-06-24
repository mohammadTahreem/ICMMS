//
//  SearchPDFView.swift
//  ICMMS
//
//  Created by Tahreem on 16/06/21.
//

import SwiftUI

struct SearchPDFView: View {
    @State var searchText: String = ""
    @State var quoteOrPurchase : String
    @State var searchFaultResponse : [FaultSearchResponse] = []
    @EnvironmentObject var settings: UserSettings
    @State var progressBarBool = false
    @State var openQuotationSheet: Bool = false
    @State var successBoolQuotation: Bool = false
    @State var quotationAccepted: Bool = false
    @State var quotationRejected: Bool = false
    var body: some View {
        VStack{
            TextField("Search for \(quoteOrPurchase)",text: $searchText)
                .onChange(of: searchText, perform: {
                    newvalue in
                    getSearchResults(searchText: newvalue)
                })
                .padding()
                .background(Color("light_gray"))
                .foregroundColor(.black)
                .cornerRadius(8)
                .padding()
            if progressBarBool {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                Spacer()
            }else{
                List (searchFaultResponse, id: \.self)  { searchFaultResponse in
                    ZStack{
                        Button("") {}
                        NavigationLink(destination: UploadQuotationView(frId: searchFaultResponse.frId!, openQuotationSheet: $openQuotationSheet, successBoolQuotation: $successBoolQuotation, quotationAccepted: $quotationAccepted, quotationRejected: $quotationRejected, viewOpenedFrom: CommonStrings().searchQuotation)){
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
        .navigationBarTitle("Search \(quoteOrPurchase)")
        .navigationBarItems(trailing: Logout().environmentObject(settings))
    }
    
    func getSearchResults(searchText: String)  {
        progressBarBool = true
        let currentUrl = CommonStrings().apiURL
        
        let urlString = "\(currentUrl)faultreport/quotationupload/search?query=\(searchText)"
        
        guard let url = URL(string: urlString) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        print(urlRequest)
        
        URLSession.shared.dataTask(with: urlRequest){data, responseCode, error in
            
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = responseCode as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                return
            }
            
            if response.statusCode == 200 {
                if let searchFaultResponse = try? JSONDecoder().decode([FaultSearchResponse].self, from: data!){
                    DispatchQueue.main.async {
                        self.searchFaultResponse = searchFaultResponse
                        print(searchFaultResponse)
                    }
                }
            }else{
                print("Error: \(response.statusCode). There was an error")
            }
            progressBarBool = false
        }.resume()
    }
}

struct SearchPDFView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPDFView(quoteOrPurchase: "Quotation")
    }
}

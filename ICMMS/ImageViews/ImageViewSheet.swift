//
//  ImageViewSheet.swift
//  ICMMS
//
//  Created by Tahreem on 18/06/21.
//

import SwiftUI

struct ImageViewSheet: View {
    
    @State var frId: String
    @State var frImageResModel: [FRImageResponseModel] = []
    @State var value : String
    @State var viewName: String
    
    var body: some View {
        
        
        Text("Images")
            .onAppear(){
                getImages()
            }
    }
    
    func getImages()  {
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/\(viewName)/\(frId)") else {return}
        
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
                
                if let currentImagesList = try? JSONDecoder().decode([FRImageResponseModel].self, from: data!){
                    DispatchQueue.main.async {
                        print(currentImagesList)
                        
                    }
                }else{
                    print("not working")
                }
                
            } else {
                print("Error code: \(response.statusCode)")
            }
        }
        dataTask.resume()
        
    }
}

//struct ImageViewSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageViewSheet()
//    }
//}

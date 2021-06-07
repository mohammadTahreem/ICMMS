//
//  ImageLoader.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    
    var downloadedImage: UIImage?
    let didChange = PassthroughSubject<ImageLoader?, Never>()
    
    let objectWillChange = PassthroughSubject<ImageLoader?, Never>()
    
    func load(url: String) {
        
        guard let imageURL = URL(string: url) else {
            fatalError("ImageURL is not correct!")
        }
        
        var urlRequest = URLRequest(url: imageURL)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.objectWillChange.send(nil)
                    print("Error: nil found")
                }
                return
            }
            
            self.downloadedImage = UIImage(data: data)
            print(data)
            DispatchQueue.main.async {
                self.objectWillChange.send(self)
                print("success: \(data)")
            }
            
        }.resume()
        
    }
    
    
}

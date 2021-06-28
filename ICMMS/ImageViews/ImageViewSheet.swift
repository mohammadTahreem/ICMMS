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
    @State var valueType : String
    @State var viewName: String
    @State var imageDataList: [ImageDataList] = []
    @State var uploadButton: Bool = true
    @State var deleteButton: Bool = false
    @State var currentFrResonse: CurrentFrResponse
    @State var showUpdateButton: Bool
    @State var imageUploadAlert: Bool = false
    @State var gettingImagesBool = true
    @State private var image: UIImage?
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentActionScheet = false
    @State private var shouldPresentCamera = false
    @State private var isImagePresent = false
    @State var deleteProgressBool : Bool = false
    @State var currentImage = ImageDataList(imageData: Data(), imageName: "")
    
    var body: some View {
        
        NavigationView{
            VStack{
                
                HStack{
                    if deleteButton {
                        if deleteProgressBool {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                .padding()
                        }else{
                            Button(action: {
                                deleteFunction()
                                deleteProgressBool = true
                            }, label: {
                                
                                Image("delete")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color(.white))
                                    .cornerRadius(40)
                            })
                        }
                    }
                    Spacer()
                    if uploadButton {
                        NavigationLink( destination:
                                            UploadImageSheet(viewName: viewName,frId: frId, imageUploadAlert: $imageUploadAlert,
                                                             image: image ?? UIImage())
                                            .onDisappear(){
                                                getImagesList()
                                                
                                            }
                                        , isActive: $isImagePresent){
                            
                            
                            Image("upload")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .onTapGesture {
                                    shouldPresentCamera = true
                                }
                                .sheet(isPresented: $shouldPresentCamera) {
                                    SUImagePickerView(
                                        image: self.$image, isPresented: self.$shouldPresentCamera)
                                        .onDisappear(){
                                            if image != UIImage() && image != nil {
                                                isImagePresent = true
                                            }
                                        }
                                }
                        }
                    }
                }
                .padding()
                if gettingImagesBool{
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .padding()
                    Spacer()
                }else{
                    TabView{
                        ForEach(imageDataList, id:\.self) { imageData in
                            VStack{
                                Image(uiImage: UIImage(data: imageData.imageData)!)
                                    .resizable()
                                    .shadow(radius: 10)
                                    .frame(width: 300, height: 500)
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .onAppear(){
                                        currentImage = imageData
                                    }
                                
                                HStack{
                                    Text("Name")
                                        .foregroundColor(.white)
                                        .padding()
                                    Spacer()
                                    Text("Contact Number")
                                        .foregroundColor(.white)
                                        .padding()
                                }
                            }
                        }
                        .onAppear(){
                            checkForConditions()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
            }
            .background(Color(.black))
            .navigationBarTitle(Text("\(viewName) Image"), displayMode: .inline)
        }
        .onAppear(){
            getImagesList()
        }
    }
    
    func deleteFunction() {
        
        var deleteImageRequest = DeleteImageRequest()
        
        for currImage in imageDataList {
            if currImage == currentImage {
                deleteImageRequest = DeleteImageRequest(image: currImage.imageName, frId: frId, type: valueType)
            }
        }
        
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/delete/image") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        urlRequest.httpBody = try? JSONEncoder().encode(deleteImageRequest)
        
        
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
                
                getImagesList()
                
            } else {
                print("Error code: \(response.statusCode)")
            }
            deleteProgressBool = false
        }
        dataTask.resume()
        
        
    }
    
    func getImagesList()  {
        self.frImageResModel.removeAll()
        self.imageDataList.removeAll()
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/\(viewName.lowercased())image/\(frId)") else {return}
        
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
                    
                    print(currentImagesList)
                    self.frImageResModel = currentImagesList
                    
                    if !frImageResModel.isEmpty{
                        for imageModelName in frImageResModel{
                            getSingleImage(imageName: imageModelName.image!)
                        }
                    }
                    else{
                        print("list is empty")
                    }
                    
                }else{
                    print("not working")
                }
                
            } else {
                print("Error code: \(response.statusCode)")
            }
            gettingImagesBool = false
        }
        dataTask.resume()
        
    }
    
    func getSingleImage(imageName: String)  {
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/getimage/\(imageName)") else {return}
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
                
                guard let imageData = data else { return }
                imageDataList.append(ImageDataList(imageData: imageData, imageName: imageName))
            } else {
                print("Error code: \(response.statusCode)")
            }
        }
        dataTask.resume()
    }
    
    func checkForConditions()  {
        if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameManag
        {
            uploadButton = false
        } else if UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech {
            
            if
                currentFrResonse.status! == CommonStrings().statusCompleted ||
                    currentFrResonse.status! == CommonStrings().statusClosed ||
                    currentFrResonse.status! == CommonStrings().statusPauseRequested ||
                    imageDataList.count >= 5
            {
                uploadButton = false
            }
            
            if imageDataList.count > 1 {
                deleteButton = true
            }
        }
    }
}




struct ImageViewSheet_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewSheet(frId: "", valueType: "", viewName: "", currentFrResonse: CurrentFrResponse(), showUpdateButton: true)
    }
}



//
//  UploadTaskImageSheet.swift
//  ICMMS
//
//  Created by Tahreem on 02/07/21.
//

import SwiftUI

struct ViewTaskImage: View {
    
    @State var ackName: String
    @State var ackContact: String
    @State var imageName: String
    @State var imageData : Data = Data()
    var imageType: String
    @State var showDeleteButton = false
    @State var showUploadButton = false
    var viewFrom : String
    var role: String = UserDefaults.standard.string(forKey: "role")!
    @State var taskId : String
    @State private var image: UIImage?
    @State var imageAlert: Bool = false
    @State var shouldPresentCamera = false
    @State var isImagePresent = false
    @State var imageIsLoading = true
    @State var deleteImageLoading = false
    @State var id: Int
    var status: String
    @State var confirmDelete: Bool = false
    
    var body: some View {
        NavigationView{
            ZStack{
                Color(.black)
                VStack{
                    
                    if imageIsLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                        Spacer()
                    }else{
                        if image != UIImage() && image != nil{
                            Image(uiImage: image!)
                                .resizable()
                                .scaledToFit()
                                .padding()
                        }else{
                            Image(uiImage: (UIImage(data: imageData) ?? UIImage(named: "noimage"))!)
                                .resizable()
                                .scaledToFit()
                                .padding()
                            
                        }
                    }
                    HStack{
                        Text(ackName)
                            .foregroundColor(.white)
                        Spacer()
                        Text(ackContact)
                            .foregroundColor(.white)
                    }
                    .padding()
                    HStack{
                        if showUploadButton{
                            NavigationLink(
                                destination: UploadTaskImageSheet(viewName: imageType, taskId: taskId,
                                                                  imageUploadAlert: $imageAlert, image: image ?? UIImage(),
                                                                  nameString: $ackName, contactNumber: $ackContact,
                                                                  id: $id, imageName: $imageName)
                                    .onDisappear(){
                                        retrieveTaskImage(imageName: imageName)
                                    },
                                isActive: $isImagePresent,
                                label: {
                                    Image("camera_icon")
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
                                })
                        }
                        Spacer()
                        if showDeleteButton{
                            if deleteImageLoading{
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding()
                            }else{
                                Button(action:{
                                    confirmDelete = true
                                },
                                label:{
                                    VStack{
                                        Image("delete")
                                            .resizable()
                                            .padding()
                                            .frame(width: 70, height: 70)
                                            .background(Color(.white))
                                            .cornerRadius(30)
                                            .shadow(radius: 10)
                                    }
                                })
                            }
                        }
                    }.padding()
                }
                .alert(isPresented: $confirmDelete) {
                    Alert(title: Text("Confirm Delete!"), message: Text("Do you wish to delete the \(imageType) image?"), primaryButton: .default(Text("Okay"), action: {
                        deleteTaskImage(id: id)
                    }), secondaryButton: .cancel())
                }
            }
            .navigationBarTitle("\(imageType) Image", displayMode: .inline)
        }
        .onAppear(){
            retrieveTaskImage(imageName: imageName)
        }
        
    }
    
    func deleteTaskImage(id: Int)  {
        deleteImageLoading = true
       
        var type = "TASK-BI-"
        if (imageType == "After") {
            type = "TASK-AI-"
        }
        
        guard let url = URL(string: "\(CommonStrings().apiURL)task/delete/image") else {return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        let body = DeleteTaskImageModel(taskId: Int(taskId), image: imageName, type: type, id: id)
        
        urlRequest.httpBody = try? JSONEncoder().encode(body)
        
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
                
                self.imageData = Data()
                self.image = UIImage()
                self.ackContact = ""
                self.ackName = ""
                if viewFrom == CommonStrings().taskScanView &&
                    role == CommonStrings().usernameTech {
                    showDeleteButton = false
                    showUploadButton = true
                }
            } else {
                print("Error code: \(response.statusCode)")
            }
        }
        dataTask.resume()
        
        deleteImageLoading = false
    }
    
    func retrieveTaskImage(imageName: String)  {
        imageIsLoading = true
        if role == CommonStrings().usernameTech && viewFrom == CommonStrings().taskScanView{
            showUploadButton = true
        }
        guard let url = URL(string: "\(CommonStrings().apiURL)task/getimage/\(imageName)") else {return}
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
                self.imageData = imageData
                imageIsLoading = false
                if viewFrom == CommonStrings().taskScanView &&
                    role == CommonStrings().usernameTech &&
                    imageData != Data() &&
                    status == CommonStrings().statusOpen
                {
                    showDeleteButton = true
                    showUploadButton = false
                }
            } else {
                print("Error code: \(response.statusCode)")
            }
        }
        dataTask.resume()
    }
    
    
}

struct ViewTaskImage_Previews: PreviewProvider {
    static var previews: some View {
        ViewTaskImage(ackName: "Name", ackContact: "Contact", imageName: "",
                      imageType: "Before",
                      viewFrom: CommonStrings().taskScanView, taskId: "",
                      id: 0, status: "Open")
    }
}






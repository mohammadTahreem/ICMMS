//
//  UploadTaskImageSheet.swift
//  ICMMS
//
//  Created by Tahreem on 06/07/21.
//

import SwiftUI
import PencilKit

struct UploadTaskImageSheet: View {
    
    @State var divisionString: String = ""
    @State var rankString : String = ""
    @State var emptyAlert = false
    @State var viewName: String
    var taskId: String
    @Binding var imageUploadAlert: Bool
    @Environment(\.presentationMode) var presentationMode
    @State var image: UIImage
    @State var uploadProgressBool = false
    @Binding var nameString: String
    @Binding var contactNumber: String
    @Binding var id: Int
    @Binding var imageName: String
    
    var body: some View {
        
        ZStack{
            Color.gray.ignoresSafeArea()
            
        VStack{
            
            TextField("Name", text: $nameString)
                .padding()
                .background(Color("light_gray"))
                .cornerRadius(8)
            TextField("Contact", text: $contactNumber).keyboardType(.numberPad)
                .onReceive(contactNumber.publisher.collect()) {
                    self.contactNumber = String($0.prefix(8))
                }
                .padding()
                .background(Color("light_gray"))
                .cornerRadius(8)
            TextField("Division", text: $divisionString)
                .padding()
                .background(Color("light_gray"))
                .cornerRadius(8)
                .alert(isPresented: $emptyAlert, content: {
                    Alert(title: Text("Please add all fields!"), dismissButton: .cancel())
                })
            
            TextField("Rank", text: $rankString)
                .padding()
                .background(Color("light_gray"))
                .cornerRadius(8)
                .alert(isPresented: $imageUploadAlert, content: {
                    Alert(title: Text("Uploaded successfully!"), dismissButton: .default(Text("Okay!"), action: {
                        presentationMode.wrappedValue.dismiss()
                    }))
                })
            
            
            if uploadProgressBool {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }else{
                Button(action: {
                    if(nameString.isEmpty &&
                        rankString.isEmpty &&
                        divisionString.isEmpty &&
                        contactNumber.isEmpty &&
                        contactNumber.count < 8){
                        uploadProgressBool = true
                        uploadImage()
                    }
                    else if nameString.isEmpty ||
                                rankString.isEmpty ||
                                divisionString.isEmpty ||
                                contactNumber.isEmpty ||
                                contactNumber.count < 8  {
                        emptyAlert = true
                    }
                    else{
                        uploadProgressBool = true
                        uploadImage()
                    }
                }, label: {
                    Text("Upload Image")
                })
                .padding()
                .background(Color("Indeco_blue"))
                .cornerRadius(8)
                .foregroundColor(.white)
                
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .padding()
        }
        .navigationBarTitle("\(viewName) Image Upload")
    }
    
    func uploadImage()  {
        
        print(image)
        
        let encodedString: String = (image.jpegData(compressionQuality: 0.2)?.base64EncodedString())!
        
        print(encodedString)
        
        let uploadTaskImageModel = UploadTaskImageModel(taskId: taskId, image: encodedString, name: nameString, contactNo: contactNumber, division: divisionString, rank: rankString)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)task/\(viewName.lowercased())image") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = try? JSONEncoder().encode(uploadTaskImageModel)
        
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
                
                if let uploadTaskImageResponse = try? JSONDecoder().decode(UploadTaskImageResponse.self, from: data!){
                    DispatchQueue.main.async {
                        self.id = uploadTaskImageResponse.id!
                        self.imageName = uploadTaskImageResponse.image!
                        print(uploadTaskImageResponse)
                    }
                } else {print("Error: Something went wrong)")
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    if let dictionary = json as? [String: Any] {
                        print(dictionary)
                    }
                }
                
                imageUploadAlert = true
                
            } else {
                print("Error code: \(response.statusCode)")
            }
            
            uploadProgressBool = false
        }
        dataTask.resume()
        
        
    }
}

struct UploadTaskImageSheet_Previews: PreviewProvider {
    static var previews: some View {
        UploadTaskImageSheet(viewName: "", taskId: "", imageUploadAlert: .constant(false), image: UIImage(),
                             nameString: .constant(""), contactNumber: .constant(""),
                             id: .constant(0), imageName: .constant(""))
    }
}

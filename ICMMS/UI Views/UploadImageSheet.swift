//
//  UploadImageSheet.swift
//  ICMMS
//
//  Created by Tahreem on 21/06/21.
//

import SwiftUI
import PencilKit

struct UploadImageSheet: View {
    
    
    @State var nameString: String = ""
    @State var contactNumber: String = ""
    @State var divisionString: String = ""
    @State var rankString : String = ""
    @State var imageAckSign = PKCanvasView()
    @State var emptyAlert = false
    @State var viewName: String
    var frId: String
    @Binding var imageUploadAlert: Bool
    @Environment(\.presentationMode) var presentationMode
    @State var image: UIImage
    @State var uploadProgressBool = false
    
    var body: some View {
        
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
                TextField("Rank", text: $rankString)
                    .padding()
                    .background(Color("light_gray"))
                    .cornerRadius(8)
                    .alert(isPresented: $imageUploadAlert, content: {
                        Alert(title: Text("Uploaded successfully!"), dismissButton: .default(Text("Okay!"), action: {
                            presentationMode.wrappedValue.dismiss()
                        }))
                    })
                
                PencilKitRepresentable(canvas: $imageAckSign)
                    .frame(height: 100.0)
                    .cornerRadius(8)
                    .border(Color.gray, width: 2)
                    .padding()
                    .alert(isPresented: $emptyAlert, content: {
                        Alert(title: Text("Please add all fields!"), dismissButton: .cancel())
                    })
            
            
            if uploadProgressBool {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }else{
                Button(action: {
                    if nameString.isEmpty ||
                        rankString.isEmpty ||
                        divisionString.isEmpty ||
                        contactNumber.isEmpty ||
                        contactNumber.count < 8 ||
                        imageAckSign.drawing.strokes.isEmpty {
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
        .navigationBarTitle("\(viewName) Image Upload")
    }
    
    func uploadImage()  {
        
        print(image)
        
        let encodedString: String = (image.jpegData(compressionQuality: 0.3)?.base64EncodedString())!
        
        print(encodedString)
        
        let uploadPictureModel =  UploadPictureRequestModel(frId: frId, image: encodedString ,name: nameString,
                                                            contact: contactNumber, division: divisionString, rank: rankString, sign: saveSignature(canvas: imageAckSign))
        
        guard let url = URL(string: "\(CommonStrings().apiURL)faultreport/\(viewName.lowercased())image") else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        urlRequest.httpBody = try? JSONEncoder().encode(uploadPictureModel)
        
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
                

                imageUploadAlert = true
                
            } else {
                print("Error code: \(response.statusCode)")
            }
            
            uploadProgressBool = false
        }
        dataTask.resume()
        
        
        }
    
    func saveSignature(canvas: PKCanvasView) -> String {
        let imageData : UIImage = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1.0)
        let originalImage = imageData.pngData()!
        return originalImage.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}


/*
 @POST("faultreport/{value}image")
 @Headers("Content-Type: application/json")
 Call<Void> uploadCaptureImage(@Path("value") String value,
 @Header("Authorization") String token,
 @Header("workspace") String workspace,
 @Body UploadPictureRequest uploadPictureRequest);
 UploadPictureRequest uploadPictureRequest = new UploadPictureRequest(frId, encodedString, name, contact, rank, division, sign);
 */

//struct UploadImageSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        UploadImageSheet(viewName: "before", frId: "frId", emptyAlert: )
//    }
//}

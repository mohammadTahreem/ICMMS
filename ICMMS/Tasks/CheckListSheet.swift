//
//  CheckListSheet.swift
//  APITestApp
//
//  Created by Mohammad Tahreem Qadri on 19/04/21.
//

import SwiftUI


struct CheckListCard: View {
    
    @Binding var checkListData : ChecklistModel
    @State var statusList: [String] = []
    @State var taskId: Int
    @Binding var enableButtonBool: Bool
    
    var body: some View {
        
        let currentStatus = Binding<String>(
            get: {checkListData.status ?? ""},
            set: {checkListData.status = $0})
        let currentRemark = Binding<String>(
            get: {checkListData.remarks ?? ""},
            set: {checkListData.remarks = $0})
        
        
        VStack{
            Text("Description").padding()
                .onAppear(){
                    addData()
                }
            if checkListData.description != nil{
                Text(checkListData.description!)
                    .padding()
            }
            Text("Status").padding()
            if checkListData.status != nil {
                Picker("Status", selection: currentStatus ) {
                    ForEach(GeneralMethods().uniqueElementsFrom(array: statusList), id: \.self){ status in
                        Text(status)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                .padding()
                .disabled(!enableButtonBool)
                
            }
            
            Text("Remarks")
            TextField("Remarks", text: currentRemark)
                .disabled(!enableButtonBool)
                .padding()
                .background(Color(.white))
                .cornerRadius(8)
                .accentColor(.gray)
            
        }
        .padding()
        .background(Color("light_gray"))
        .foregroundColor(.black)
        .cornerRadius(8)
        .shadow(radius: 10)
        .padding()
    }
    
    func addData() {
        statusList.append("Yes")
        statusList.append("no")
        statusList.append("na")
        
        
        if checkListData.status != nil {
            statusList.append(checkListData.status!)
        }
    }
}

struct CheckListSheet: View {
    
    @State var taskId: Int
    @State var pmTaskResponse : PmTaskResponse
    @State var checklistResponse: [ChecklistModel] = [ChecklistModel()]
    @State var enableButtonBool: Bool = false
    @State var currentRemarks = ""
    @State var currentStatus = ""
    @State var statusList : [String] = []
    @Binding var clSheetBool : Bool
    @State var successAlert: Bool = false
    @State var errorAlert: Bool = false
    @State var isLoading = false
    @State var viewFrom : String

    var body: some View {
        VStack{
            Text("Checklist Items")
                .padding()
                .font(.title)
                .alert(isPresented: $errorAlert) { () -> Alert in
                    Alert(title: Text("Error"), message: Text("There was an error."), dismissButton: .cancel())
                }
            
            ScrollView{
                
                ForEach(checklistResponse.indices, id:\.self) { index in
                    CheckListCard(checkListData: $checklistResponse[index],
                                  taskId: taskId,
                                  enableButtonBool: $enableButtonBool)
                        
                        .alert(isPresented: $successAlert) { () -> Alert in
                            Alert(title: Text("Updated"), message: Text("Successfully Updated"), dismissButton: .default(Text("Okay!")){
                                self.clSheetBool = false
                            })
                        }
                }
                
                if enableButtonBool{
                    if isLoading{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }else{
                        Button("Update"){
                            updateCheckList()
                        }.frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Indeco_blue"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding()
                    }
                }
            }
            .onAppear(){
                getChecklists()
            }
        }
    }
    
    func updateCheckList()  {
        isLoading = true
        var updateCheckListObject: [UpdateCheckListModel] = []
        
        for checklist in checklistResponse {
            updateCheckListObject.append(UpdateCheckListModel(id: checklist.id, taskId: taskId,
                                                              remarks: checklist.remarks, status: checklist.status))
        }
        
        print(updateCheckListObject)
        
        guard let url = URL(string: "\(CommonStrings().apiURL)task/updateChecklists") else {return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        let encodedBody = try? JSONEncoder().encode(updateCheckListObject)
        urlRequest.httpBody = encodedBody
        
        print(urlRequest)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                self.errorAlert = true
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("response error: \(String(describing: error))")
                self.errorAlert = true
                return
            }
            
            if response.statusCode == 200 {
                guard let _ = data else { return }
                self.successAlert = true
            } else {
                print("Error code: \(response.statusCode)")
                self.errorAlert = true
            }
            isLoading = false
        }
        
        dataTask.resume()
    }
    
    
    func getChecklists()  {
        guard let url = URL(string: "\(CommonStrings().apiURL)task/\(taskId)/checklist") else {
            return
        }
        var urlRequest = URLRequest(url: url)
        
        if (UserDefaults.standard.string(forKey: "role") == CommonStrings().usernameTech
                && pmTaskResponse.status! == "Open") && viewFrom == CommonStrings().taskScanView {
            enableButtonBool = true
        }
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "token"), forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaults.standard.string(forKey: "role"), forHTTPHeaderField: "role")
        urlRequest.setValue( UserDefaults.standard.string(forKey: "workspace"), forHTTPHeaderField: "workspace")
        
        print(urlRequest)
        
        URLSession.shared.dataTask(with: urlRequest){ data, _, _ in
            if let checklistResponse = try? JSONDecoder().decode([ChecklistModel].self, from: data!){
                DispatchQueue.main.async {
                    self.checklistResponse = checklistResponse
                    print(checklistResponse)
                }
            }else{
                print("something wrong")
            }
        }.resume()
    }
}

struct CheckListSheet_Previews: PreviewProvider {
    static var previews: some View {
        
        CheckListSheet(taskId: 1, pmTaskResponse: PmTaskResponse(), clSheetBool: .constant(true), viewFrom: "")
        
    }
}

//
//  SignView.swift
//  ICMMS
//
//  Created by Tahreem on 08/07/21.
//

import SwiftUI

struct SignView: View {
    var url: String
    var body: some View {
        VStack{
            Text("Acknowledger Signature")
                .padding()
            HStack{
                Spacer()
            URLImage(url: url)
                .scaledToFit()
                .padding()
                .cornerRadius(8)
                Spacer()
            }
        }
        .background(Color("light_gray"))
        .foregroundColor(.black)
        .cornerRadius(8)
        .padding()
    }
}

struct SignView_Previews: PreviewProvider {
    static var previews: some View {
//        SignView(url: "")
        TestView()
    }
}

struct TestView: View {
    
    @State var selectedManagingAgent: Int = 0
    @State var fmmList: [Fmm] = [Fmm(username: "sadas", id: 11),
    Fmm(username: "askjdaskjd", id: 22)]
    
    
    var body: some View{
        VStack{
            Picker(selection: $selectedManagingAgent, label: Text("Select ManagingAgent")) {
                ForEach(0 ..< fmmList.count){
                    Text(self.fmmList[$0].username).tag($0)
                }
            }.pickerStyle(MenuPickerStyle())
            HStack{
                Spacer()
            Text(fmmList[selectedManagingAgent].username).padding()
                Spacer()
            }
        }.padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


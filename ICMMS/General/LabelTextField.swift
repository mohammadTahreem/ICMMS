//
//  LabelTextField.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation
import SwiftUI

struct LabelTextField : View {
    var label: String
    @State var placeHolder: String
    @State var disableBool : Bool?
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            TextField("", text: $placeHolder)
                .padding(.all)
                .background(Color("light_gray"))
                .cornerRadius(8)
                .disabled(disableBool ?? true)
                .foregroundColor(checkForCondition(label: label, placeHolder: placeHolder))
        }
        .padding(.leading)
        .padding(.trailing)
    }
    
    func checkForCondition(label: String, placeHolder: String) -> Color {
        if(label == placeHolder){
            return Color.secondary
        }else{
            return Color.black
        }
    }
    
}



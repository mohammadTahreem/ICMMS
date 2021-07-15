//
//  FloatingMenu.swift
//  ICMMS
//
//  Created by Tahreem on 18/06/21.
//

import SwiftUI


struct MenuItem: View {
    var icon: String
    var body: some View{
        Image(icon)
            .resizable()
            .padding()
            .frame(width: 60, height: 60)
            .background(Color(.white))
            .cornerRadius(30)
            .shadow(radius: 10)
        
        
    }
}

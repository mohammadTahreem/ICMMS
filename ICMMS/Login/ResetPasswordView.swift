//
//  ResetPasswordView.swift
//  ICMMS
//
//  Created by Tahreem on 07/07/21.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var emailAddress: String = ""
    var body: some View {
        VStack{
            TextField("Email Address", text: $emailAddress)
                .padding()
                .cornerRadius(8)
                
            Button {
                if !emailAddress.isEmpty && emailAddress.isValidEmail {
                    //send email
                    print(emailAddress)
                }else{
                    print("wrong email: \(emailAddress)")
                }
            } label: {
                Text("Send Email to reset Password")
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
        .shadow(radius: 10)
        
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}

extension String {
    
    var isValidEmail: Bool {
        let name = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let domain = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegEx = name + "@" + domain + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    
}

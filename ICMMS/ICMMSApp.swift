//
//  ICMMSApp.swift
//  ICMMS
//
//  Created by Mohammad Tahreem Qadri on 01/06/21.
//

import SwiftUI
import Firebase

@main
struct ICMMSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var
        delegate
    @State var fcmRegTokenMessage = ""
    @State var message : [String: Any] = [:]

    var body: some Scene {
        
        WindowGroup {
            MainScreen()
                .environmentObject(UserSettings())
                .onAppear(){
                    Messaging.messaging().token { token, error in
                      if let error = error {
                        print("Error in FCM Token: \(error)")
                      } else if let token = token {
                        self.fcmRegTokenMessage = "Remote FCM registration token: \(token)"
                        UserDefaults.standard.setValue(token, forKey: "deviceToken")
                        UserDefaults.standard.synchronize()
                      }
                    }
                }
        }
    }
}

//
//  AcceptPauseSheet.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation
import SwiftUI


struct AcceptPauseSheet: View {
    @State var acceptRejectModel: AcceptRejectModel
    @Binding var acceptSheetBool: Bool
    var body: some View {
        Button("Pick PDF"){
            // open documents where we can add the pdf to webview
            print("clicked")
        }
    }
}

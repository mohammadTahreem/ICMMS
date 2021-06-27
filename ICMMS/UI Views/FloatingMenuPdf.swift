//
//  FloatingMenu.swift
//  ICMMS
//
//  Created by Tahreem on 18/06/21.
//

import SwiftUI

struct FloatingMenuPdf: View {
    
    @State var showMenuItem1 = false
    @State var showMenuItem2 = false
    @State var moreIcon: String
    @State var purchaseImage: String
    @State var quoteImage: String
    @State var frId: String
    @Binding var successBoolQuotation: Bool
    @Binding var openQuotationSheet: Bool
    @Binding var openPurchaseSheet : Bool
    @Binding var successBoolPurchase : Bool
    @State var currentFrResponse: CurrentFrResponse
    @State var showUpdateButton: Bool
    @State var quotationAccepted: Bool = false
    @State var quotationRejected: Bool = false
    
    
    var body: some View {
        VStack{
            
            Spacer()
            if showMenuItem1 {
                MenuItem(icon: quoteImage)
                    .onTapGesture {
                        openQuotationSheet = true
                    }
                .sheet(isPresented: $openQuotationSheet, content: {
                    UploadQuotationView(frId: frId, openQuotationSheet: $openQuotationSheet,
                                        successBoolQuotation: $successBoolQuotation, quotationAccepted: $quotationAccepted, quotationRejected: $quotationRejected, currentFrResponse: currentFrResponse, viewOpenedFrom: CommonStrings().editFaultReportActivity)
                })
            }
            if showMenuItem2 {
                MenuItem(icon: purchaseImage)
                    .onTapGesture {
                        openPurchaseSheet = true
                    }
                    .sheet(isPresented: $openPurchaseSheet, content: {
                        UploadPurchaseOrderView(frId: frId, currentFrResponse: currentFrResponse)
                    })
            }
            
            
            Button(action: {
                showMenu()
            }) {
                Image(moreIcon)
                    .resizable()
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(Color(.white))
                    .cornerRadius(30)
                    .shadow(radius: 10)
                    
            }
            
        }
    }
    func showMenu() {
        showMenuItem2.toggle()
        showMenuItem1.toggle()
    }
}

struct FloatingMenu_Previews: PreviewProvider {
    static var previews: some View {
        MenuItem(icon: "fabback")
    }
}

struct MenuItem: View {
    var icon: String
    var body: some View{
        Image(icon)
            .resizable()
            .padding()
            .frame(width: 50, height: 50)
            .background(Color(.white))
            .cornerRadius(30)
            .shadow(radius: 10)
        
        
    }
}


struct FloatingMenuImages: View {
    
    @State var showMenuItem1 = false
    @State var showMenuItem2 = false
    @State var moreIcon: String
    @State var purchaseImage: String
    @State var quoteImage: String
    @State var frId: String
    @Binding var successBeforeImageBool: Bool
    @Binding var openBeforeImageSheetBool: Bool
    
    @Binding var openAfterImageSheetBool : Bool
    @Binding var successBeforeImageSheetBool : Bool
    @State var currentFrResponse: CurrentFrResponse
    @State var showUpdateButton: Bool
    var body: some View {
        VStack{
            
            Spacer()
            if showMenuItem1 {
                MenuItem(icon: "beforeupload")
                    .onTapGesture {
                        openBeforeImageSheetBool = true
                    }
                    .sheet(isPresented: $openBeforeImageSheetBool, content: {
                        ImageViewSheet(frId: frId, valueType: "FR-BI-", viewName: "Before", currentFrResonse: currentFrResponse, showUpdateButton: showUpdateButton)
                    })
            }
            if showMenuItem2 {
                MenuItem(icon: "afterupload")
                    .onTapGesture {
                        openAfterImageSheetBool = true
                    }
                    .sheet(isPresented: $openAfterImageSheetBool, content: {
                        ImageViewSheet(frId: frId, valueType: "FR-AI-", viewName: "After", currentFrResonse: currentFrResponse, showUpdateButton: showUpdateButton)
                    })
            }
            
            
            Button(action: {
                showMenu()
            }) {
                Image("fabback")
                    .resizable()
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(Color(.white))
                    .cornerRadius(30)
                    .shadow(radius: 10)
                
            }
            
        }
    }
    func showMenu() {
        showMenuItem2.toggle()
        showMenuItem1.toggle()
    }
}

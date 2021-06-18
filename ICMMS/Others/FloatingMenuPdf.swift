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
    
    var body: some View {
        VStack{
            
            Spacer()
            if showMenuItem1 {
                MenuItem(icon: quoteImage)
                    .onTapGesture {
                        openQuotationSheet = true
                    }
                .sheet(isPresented: $openQuotationSheet, content: {
                    UploadQuotationView(frId: frId, openQuotationSheet: $openQuotationSheet, successBoolQuotation: $successBoolQuotation)
                })
            }
            if showMenuItem2 {
                MenuItem(icon: purchaseImage)
                    .onTapGesture {
                        openPurchaseSheet = true
                    }
                    .sheet(isPresented: $openPurchaseSheet, content: {
                        UploadPurchaseOrderView(frId: frId)
                    })
            }
            
            
            Button(action: {
                showMenu()
            }) {
                Image(moreIcon)
                    .resizable()
                    .padding()
                    .frame(width: 80, height: 80)
                    .background(Color(.white))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    
            }
            
        }
    }
    func showMenu() {
        showMenuItem2.toggle()
        showMenuItem1.toggle()
    }
}

//struct FloatingMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        FloatingMenu(moreIcon: "newquote", purchaseImage: "quote_p", quoteImage: "quote_q")
//    }
//}

struct MenuItem: View {
    var icon: String
    var body: some View{
        Image(icon)
            .resizable()
            .padding()
            .frame(width: 70, height: 70)
            .background(Color(.white))
            .cornerRadius(20)
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
    
    var body: some View {
        VStack{
            
            Spacer()
            if showMenuItem1 {
                MenuItem(icon: "beforeupload")
                    .onTapGesture {
                        openBeforeImageSheetBool = true
                    }
                    .sheet(isPresented: $openBeforeImageSheetBool, content: {
                        ImageViewSheet(frId: frId, value: "FR-BI-", viewName: "beforeimage")
                    })
            }
            if showMenuItem2 {
                MenuItem(icon: "afterupload")
                    .onTapGesture {
                        openAfterImageSheetBool = true
                    }
                    .sheet(isPresented: $openAfterImageSheetBool, content: {
                        ImageViewSheet(frId: frId, value: "FR-AI-", viewName: "afterimage")
                    })
            }
            
            
            Button(action: {
                showMenu()
            }) {
                Image("fabback")
                    .resizable()
                    .padding()
                    .frame(width: 80, height: 80)
                    .background(Color(.white))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
            }
            
        }
    }
    func showMenu() {
        showMenuItem2.toggle()
        showMenuItem1.toggle()
    }
}

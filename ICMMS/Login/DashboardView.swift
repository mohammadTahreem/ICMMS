//
//  DashboardView.swift
//  ICMMS
//
//  Created by Tahreem on 02/06/21.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var settings: UserSettings
    @State var showScanSheet = false
    @State var qrValue = ""
    let workspace : String
    
    var columns: [GridItem] = [
        GridItem(.fixed(150), spacing: 30),
        GridItem(.fixed(150), spacing: 30)
    ]
    
    var body: some View {
        
        let dashboardDetails = DashboadDetails.demo
        ZStack{
            Color.secondary
                .edgesIgnoringSafeArea(.all)
            LazyVGrid(columns: columns, spacing: 20){
                
                ForEach(dashboardDetails){ dashboardDetails in
                    NavigationLink(destination: destination(dashDetails: dashboardDetails)){
                        VStack{
                            Image(dashboardDetails.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            Text(dashboardDetails.itemName)
                                .lineLimit(0)
                                .font(.caption)
                                .foregroundColor(Color("Indeco_blue"))
                        }.padding()
                    }
                }
                
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 20)
            }.frame(width: 150, height: 150)
            .navigationBarTitle("Dashboard")
            .navigationBarItems (
                trailing: Logout().environmentObject(settings)
            )
        }
        .onAppear(){
            saveWorkSpaceInUserDeaults(workspace: workspace)
        }
    }
    
    @ViewBuilder func destination(dashDetails: DashboadDetails) -> some View {
        switch dashDetails.viewName {
        case .searchFaultReportView:
            SearchFaultReportView()
        case .scanFaultReportView:
            //EquipScanView(showScanSheet: $showScanSheet, QRValue: $qrValue, frId: <#T##String#>, responseCode: <#T##Binding<String>#>)
        Text("scan fault")
        case .searchPOView:
            SearchPDFView(quoteOrPurchase: "Purchase Order")
        case .searchQoutView:
            SearchPDFView(quoteOrPurchase: "Quotation")
//        case .taskScanView:
//            Text("Scan Tasks")
//        case .taskSearchView:
//            Text("TSV")
        }
    }
    
    func saveWorkSpaceInUserDeaults(workspace: String) {
        UserDefaults.standard.setValue(workspace, forKey: "workspace")
        UserDefaults.standard.synchronize()
    }
    
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    
    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                    ForEach(0 ..< columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }
    
    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}


struct DashBoardPreview: PreviewProvider {
    static var previews: some View {
        DashboardView(workspace: "asd")
    }
}

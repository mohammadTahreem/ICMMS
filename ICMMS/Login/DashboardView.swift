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
    let user = UserDefaults.standard.string(forKey: "role")
    @State var demo: [DashboadDetails] = []
    
    var body: some View {
        
        ZStack{
            Color.secondary
                .edgesIgnoringSafeArea(.all)
            LazyVGrid(columns: columns, spacing: 20){
                
                ForEach(demo){ dashboardDetails in
                    NavigationLink(destination: destination(dashDetails: dashboardDetails)){
                        VStack{
                            Image(dashboardDetails.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .scaledToFit()
                            Text(dashboardDetails.itemName)
                                .font(.caption)
                                .foregroundColor(Color("Indeco_blue"))
                        }.padding()
                        .frame(width: 150, height: 150, alignment: .center)
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
            .onAppear(){
                saveWorkSpaceInUserDeaults(workspace: workspace)
                demo = []
                demo = [DashboadDetails(imageName: "searchfault", itemName: "Search Fault Report", viewName: .searchFaultReportView),
                        DashboadDetails(imageName: "scanfault", itemName: "Scan Fault Report", viewName: .scanFaultReportView),
                        DashboadDetails(imageName: "tasksearch", itemName: "Task Search", viewName: .taskSearchView)]
                if user == CommonStrings().usernameTech{
                    demo.append(DashboadDetails(imageName: "purchase_qoutation", itemName: "Upload Qoutation", viewName: .searchQoutView))
                    demo.append(DashboadDetails(imageName: "taskscan", itemName: "Task Scan", viewName: .taskScanView))
                    demo.append(DashboadDetails(imageName: "purchase_order", itemName: "Upload Purchase Order", viewName: .searchPOView))
                }else{
                    demo.append(DashboadDetails(imageName: "purchase_qoutation", itemName: "Search Qoutation", viewName: .searchQoutView))
                    demo.append(DashboadDetails(imageName: "purchase_order", itemName: "Search Purchase Order", viewName: .searchPOView))
                }
                
            }
        }
    }
    
    @ViewBuilder func destination(dashDetails: DashboadDetails) -> some View {
        switch dashDetails.viewName {
        case .searchFaultReportView:
            SearchFaultReportView()
        case .scanFaultReportView:
            ScanFaultEquipView()
        case .searchPOView:
            SearchPDFView(quoteOrPurchase: "Purchase Order")
        case .searchQoutView:
            SearchPDFView(quoteOrPurchase: "Quotation")
        case .taskScanView:
            TaskScanView().environmentObject(settings)
        case .taskSearchView:
            TaskSearchView().environmentObject(settings)
        }
    }
    
    func saveWorkSpaceInUserDeaults(workspace: String) {
        UserDefaults.standard.setValue(workspace, forKey: "workspace")
        UserDefaults.standard.synchronize()
    }
    
}


struct DashBoardPreview: PreviewProvider {
    static var previews: some View {
        DashboardView(workspace: "asd").environmentObject(UserSettings())
    }
}

//
//  GeneralItems.swift
//  ICMMS
//
//  Created by Tahreem on 16/06/21.
//

import Foundation
import SwiftUI
struct GeneralItems: View {
    
    @State var frId: String
    @State var currentFrResponse: CurrentFrResponse
    @Binding var observationString: String
    @Binding var actionTakenString: String
    
    var body: some View{
        VStack{
            
            LabelTextField(label: "Case Id", placeHolder: frId)
            
            if(currentFrResponse.department != nil && currentFrResponse.department?.name != nil){
                LabelTextField(label: "Department", placeHolder: currentFrResponse.department!.name!)
            } else{
                LabelTextField(label: "Department", placeHolder: "Department")
            }
            
            if(currentFrResponse.requestorName != nil){
                LabelTextField(label: "Requestor Name", placeHolder: currentFrResponse.requestorName!)
            }else{
                LabelTextField(label: "Requestor Name", placeHolder: "Requestor Name")
            }
            
            if(currentFrResponse.activationTime != nil){
                LabelTextField(label: "Activation Date",
                               placeHolder:GeneralMethods().convertTStringToString(isoDate: currentFrResponse.activationTime!))
            }else{
                LabelTextField(label: "Activation Date", placeHolder: "Activation Date")
            }
            
            if(currentFrResponse.arrivalTime != nil){
                LabelTextField(label:"Arrival Date",
                               placeHolder: GeneralMethods().convertTStringToString(isoDate: currentFrResponse.arrivalTime!))
            }else{
                LabelTextField(label: "Arrival Date", placeHolder: "Arrival Date")
            }
            
            if(currentFrResponse.responseTime != nil){
                LabelTextField(label: "Response Time", placeHolder:currentFrResponse.responseTime!)
            }else{
                LabelTextField(label: "Response Time", placeHolder: "Response Time")
            }
            
            if(currentFrResponse.acknowledgementTime != nil){
                LabelTextField(label: "Acknowledge Time", placeHolder:GeneralMethods().convertTStringToString(isoDate: currentFrResponse.acknowledgementTime!))
            }else{
                LabelTextField(label: "Acknowledge Time", placeHolder: "Acknowledge Time")
            }
            
            if(currentFrResponse.downTime != nil){
                LabelTextField(label: "Down Time", placeHolder:currentFrResponse.downTime!)
            }else{
                LabelTextField(label: "Down Time", placeHolder: "Down Time")
            }
            
            if(currentFrResponse.eotTime != nil){
                LabelTextField(label: "EOT", placeHolder:currentFrResponse.eotTime!)
            }else{
                LabelTextField(label: "EOT", placeHolder: "EOT")
            }
            
            if(currentFrResponse.eotType != nil){
                LabelTextField(label: "Required EOT Time", placeHolder: currentFrResponse.eotType!)
            }else{
                LabelTextField(label: "Required EOT Time", placeHolder: "Required EOT Time")
            }
        }
        
        VStack{
            //not editable
            VStack{
                if(currentFrResponse.requestorContactNo != nil){
                    LabelTextField(label: "Contact Number", placeHolder:currentFrResponse.requestorContactNo!)
                }else{
                    LabelTextField(label: "Contact Number", placeHolder: "Contact Number")
                }
                
                if(currentFrResponse.priority != nil && currentFrResponse.priority?.name != nil) {
                    LabelTextField(label: "Priority", placeHolder:currentFrResponse.priority!.name!)
                }else{
                    LabelTextField(label: "Priority", placeHolder: "Priority")
                }
                
                if(currentFrResponse.building != nil && currentFrResponse.building?.name != nil) {
                    LabelTextField(label: "Building", placeHolder: currentFrResponse.building!.name!)
                }else{
                    LabelTextField(label: "Building", placeHolder: "Building")
                }
                
                if(currentFrResponse.location != nil && currentFrResponse.location?.name != nil){
                    LabelTextField(label: "Location", placeHolder: currentFrResponse.location!.name!)
                }else{
                    LabelTextField(label: "Location", placeHolder: "Location")
                }
                
                if(currentFrResponse.division != nil && currentFrResponse.division?.name != nil){
                    LabelTextField(label: "Division", placeHolder: currentFrResponse.division!.name!)
                }else{
                    LabelTextField(label: "Division", placeHolder: "Division")
                }
                
                if(currentFrResponse.locationDesc != nil){
                    LabelTextField(label: "Location Description", placeHolder: currentFrResponse.locationDesc!)
                }else{
                    LabelTextField(label: "Location Description", placeHolder: "Location Description")
                }
                
                if(currentFrResponse.faultCategory != nil && currentFrResponse.faultCategory?.name != nil){
                    LabelTextField(label: "Fault Category", placeHolder: currentFrResponse.faultCategory!.name!)
                }else{
                    LabelTextField(label: "Fault Category", placeHolder: "Fault Category")
                }
                
                if(currentFrResponse.faultCategoryDesc != nil){
                    LabelTextField(label: "Fault Description", placeHolder: currentFrResponse.faultCategoryDesc!)
                }else{
                    LabelTextField(label: "Fault Description", placeHolder: "Fault Description")
                }
                
                if(currentFrResponse.maintGrp != nil && currentFrResponse.maintGrp?.name != nil ){
                    LabelTextField(label: "Maintenance Group", placeHolder: currentFrResponse.maintGrp!.name!)
                }else{
                    LabelTextField(label: "Maintenance Group", placeHolder: "Maintenance Group")
                }
            }
            
            //Observation and Action Taken
            VStack{
                
                Section(header: HStack{Text("Observation")
                    .font(.headline)
                    Spacer()
                }){
                    TextField("Observation", text: $observationString)
                        .padding()
                        .background(Color("light_gray"))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 15)
                
                Section(header: HStack{Text("ActionTaken")
                    .font(.headline)
                    Spacer()
                }){
                    TextField("Action Taken", text: $actionTakenString)
                        .padding()
                        .background(Color("light_gray"))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }.padding(.horizontal, 15)
                
                
                if(currentFrResponse.equipment != nil && currentFrResponse.equipment?.name != nil){
                    LabelTextField(label: "Equipment", placeHolder: currentFrResponse.equipment!.name!)
                }else{
                    LabelTextField(label: "Equipment", placeHolder: "Equipment")
                }
            }
        }
    }
}

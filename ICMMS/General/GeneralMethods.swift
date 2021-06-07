//
//  GeneralMethods.swift
//  ICMMS
//
//  Created by Tahreem on 03/06/21.
//

import Foundation

struct GeneralMethods {
    func convertLongToString(isoDate: Int)-> String{
        let epochTime = TimeInterval(isoDate) / 1000
        let date = Date(timeIntervalSince1970: epochTime)
        
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    func convertLongToDate(isoDate: Int) -> String {
        let epochTime = TimeInterval(isoDate) / 1000
        let date = Date(timeIntervalSince1970: epochTime)
        
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd-MM-yyyy"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    func convertTStringToString(isoDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from:isoDate)!
        
        let dateFormatter2 = DateFormatter()
        
        // Set Date Format
        dateFormatter2.dateFormat = "dd-MM-yyyy HH:mm"
        
        // Convert Date to String
        let stringDate = dateFormatter2.string(from: date)
        
        return stringDate
    }
    
    func uniqueElementsFrom(array: [String]) -> [String] {
        //Create an empty Set to track unique items
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0) else {
                //If the set already contains this object, return false
                //so we skip it
                return false
            }
            //Add this item to the set since it will now be in the array
            set.insert($0)
            //Return true so that filtered array will contain this item.
            return true
        }
        return result
    }
    
    func currentTimeInMiliseconds(currentDate: Date) -> Int! {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from: dateFormatter.string(from: currentDate as Date))
        let nowDouble = date!.timeIntervalSince1970
        return Int(nowDouble*1000)
    }
    
}

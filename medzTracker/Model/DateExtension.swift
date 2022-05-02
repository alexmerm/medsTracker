//
//  DateExtension.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/30/22.
//

import Foundation
extension Date {
    
    static var relativeDateFormatter = Model.relativeDateFormatter
    static var timeOnlyFormatter = Model.dateFormatter
    var relativeFormattedString :String {
        Date.relativeDateFormatter.string(from: self)
    }
    var timeOnlyFormattedString : String{
        Date.timeOnlyFormatter.string(from: self)
    }
    
    var asDateComponents :DateComponents {
        let cal = Calendar.current
        return cal.dateComponents([.hour,.minute,.timeZone,.month,.year,.day,.calendar,.second], from: self)
    }
    
}

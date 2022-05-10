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
    
    var justTimeSince1970 : TimeInterval  {
        let cal = Calendar.current
        //Get midnight UTC for this day
        let startOfDayDouble = cal.startOfDay(for: self).timeIntervalSince1970 + Double(cal.timeZone.secondsFromGMT())
        //Return this date's time on a standardizedDate
        return self.timeIntervalSince1970 - startOfDayDouble
    }
    
}

extension TimeInterval {
    static var fullDateComponentsFormatter = Model.fullDateComponentsFormatter
    
    var fullString : String {
        return TimeInterval.fullDateComponentsFormatter.string(from: self) ?? ""
    }
}

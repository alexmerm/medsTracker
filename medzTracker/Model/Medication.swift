//
//  Medication.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/9/22.
//

import Foundation
struct Medication : Equatable,Identifiable {
    //ID
    let id = UUID()
    enum Schedule : Hashable {
        case intervalSchedule(interval: TimeInterval)
        case specificTime(time: Date)
        case asNeeded
    }
    //define variables
    var name : String
    var dosage : Int?
    var dosageUnit : String?
    var schedule : Schedule
    var maxDosage : Int?
    var reminders : Bool
    var pastDoses :[Dosage]
    var dateComponentsFormatter : DateComponentsFormatter
    var dateFormatter : DateFormatter
    
    var readableDosage : String? {
        if let dosage = dosage, let dosageUnit = dosageUnit {
            return "\(dosage) \(dosageUnit)"
        } else {
            return nil
        }
    }
    
    struct Dosage {
        var time : Date
        var amount : Int
        var dateComponentsFormatter : DateComponentsFormatter
        var dateFormatter : DateFormatter
        
        var timeSinceDosageString : String {
            dateComponentsFormatter.string(from: time,to: .now) ?? ""
        }
        var timeString : String {
            dateFormatter.string(from: time)
        }
    }
    
    mutating func logDosage(time : Date, amount : Int) {
        pastDoses.append(Dosage(time: time, amount: amount, dateComponentsFormatter: dateComponentsFormatter, dateFormatter: dateFormatter))
        //In theory, this should go from back of the array and insert at a sorted place, but I'm not doing that right this second
        pastDoses.sort(by: {$0.time < $1.time})
    }
    
    //Returns the Latest Dosage
    func getLatestDosage() -> Dosage? {
        return pastDoses.last
    }
    
    //Equatable protocol
    static func == (lhs: Medication, rhs: Medication) -> Bool {
        //TODO: Assign like an ID or smth to that you cant have 2 of the same type
        lhs.id == rhs.id
    }
    
}

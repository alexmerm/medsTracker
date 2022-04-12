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
    enum DosageUnit : CaseIterable, Hashable {        
        static var allCases: [DosageUnit] {
            return [mg, mcg, g,kg,ml,L,cc,pills,tablets] //Excluding other unit
        }
        case mcg
        case mg
        case g
        case kg
        case L
        case ml
        case cc
        case pills
        case tablets
        case other(unit : String)
        var description : String {
            switch self {
            case .mg:
                return "mg"
            case .g:
                return "g"
            case .kg:
                return "kg"
            case .mcg:
                return "mcg"
            case .L:
                return "L"
            case .ml:
                return "ml"
            case .cc:
                return "cc"
            case .pills:
                return "pills"
            case .tablets:
                return "tablets"
            case .other(let unit):
                return unit
            }
        }
    }
    var dosage : Double?
    var dosageUnit : DosageUnit?
    var schedule : Schedule
    var maxDosage : Int?
    var reminders : Bool
    var pastDoses :[Dosage]
    var dateComponentsFormatter : DateComponentsFormatter
    var dateFormatter : DateFormatter
    var readableDosage : String? {
        if let dosage = dosage, let dosageUnit = dosageUnit {
            return "\(dosage) \(dosageUnit.description)"
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

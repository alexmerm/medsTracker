//
//  Medication.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/9/22.
//

import Foundation
struct Medication : Equatable,Identifiable, Codable {
    //Default Initializer
    internal init(name: String, dosage: Double? = nil, dosageUnit: Medication.DosageUnit? = nil, schedule: Medication.Schedule, maxDosage: Int? = nil, reminders: Bool, pastDoses: [Medication.Dosage]) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.dosageUnit = dosageUnit
        self.schedule = schedule
        self.maxDosage = maxDosage
        self.reminders = reminders
        self.pastDoses = pastDoses
        self.creationTime = Date()
    }
    
    //ID
    let id : UUID
    enum Schedule : Hashable, Codable {
        case intervalSchedule(interval: TimeInterval)
        case specificTime(hour: Int, minute: Int) //store in 24hourTime
        case asNeeded
        func typeString() -> String{
            switch self {
            case .intervalSchedule( _):
                return "Interval"
            case .specificTime( _,  _):
                return "Specific Time"
            case .asNeeded:
                return "As Needed"
            }
        }
    }
    //define variables
    var name : String
    enum DosageUnit : CaseIterable, Hashable, Codable {
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
    
    let creationTime : Date //Signifies what time the medication was added
    static let calendar = Calendar.autoupdatingCurrent
    
    
    

    var readableDosage : String? {
        if let dosage = dosage, let dosageUnit = dosageUnit {
            return "\(dosage) \(dosageUnit.description)"
        } else {
            return nil
        }
    }
    //TODO: make intetval into like "every x hours, x min", and other into "every day at"
    var readableSchedule : String? {
        switch schedule {
        case .intervalSchedule(let interval):
            return MedsDB.getDateComponentFormatter().string(from: interval)
        case .specificTime(hour: let hour, minute: let minute):
            let date = Date()
            let d2 = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)
            return d2?.formatted()
        case .asNeeded:
            return nil
        }
    }
    
    struct Dosage : Codable {
        var time : Date
        var amount : Int
        static let dateComponentsFormatter : DateComponentsFormatter = MedsDB.getDateComponentFormatter()
        static let  dateFormatter : DateFormatter = MedsDB.getDateFormatter()
        
        var timeSinceDosageString : String {
            Medication.Dosage.dateComponentsFormatter.string(from: time,to: .now) ?? ""
        }
        var timeString : String {
            Medication.Dosage.dateFormatter.string(from: time)
        }
    }
    
    mutating func logDosage(time : Date, amount : Int) {
        pastDoses.append(Dosage(time: time, amount: amount))
        //In theory, this should go from back of the array and insert at a sorted place, but I'm not doing that right this second
        pastDoses.sort(by: {$0.time < $1.time})
    }
    
    //Returns the Latest Dosage
    func getLatestDosage() -> Dosage? {
        return pastDoses.last
    }
    
    var overdue : Bool {

        ///1. Check if added today
        ///     a. for interval:
        ///             b. if there is a latestDosage, return true if it  latestDosage + Interval < currTime
        ///             c. otherwise, return false
        ///     b. for Scheduletime:
        ///             a. if added today:
        ///                     a. if scheduleTime today is < (>) addedTime, then return false
        ///                     b. otherwise, if currTime > scheduleTime today, then return true , otherwise false (so actually pass thru to default)
        ///             b. if not added today:
        ///                     c. if currTime > schedultTime today, return true , otherwise return false
        ///      c. for asNeeded : return false
        ///
    
        let nextDosageTime = getNextDosageTime()
        if nextDosageTime != nil {
            return true
        } else {
            return false
        }

    }
    
    
    func getNextDosageTime() -> Date? {
        switch schedule {
        case .intervalSchedule(let interval): // return latestDosage + Interval, if its never been taken, return nothing
            if let lastestDosage = getLatestDosage() {
                return lastestDosage.time + interval
            } else {
                return nil
            }
        case .specificTime(hour: let hour, minute: let minute):
            guard let scheduledTimeToday = Medication.calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) else {
                return nil //There is no way this will return negative, but we need to avoid the optional neatly-ish
            }
            //if medication was created today
            if Medication.calendar.isDateInToday(creationTime) {
                //if was created after the time it was scheduled
                if scheduledTimeToday < creationTime {
                    //return tommorow's time
                    return Medication.calendar.date(byAdding: .day, value: 1, to: scheduledTimeToday)
                }
                //otherwise if the current time is passed the scheudleTime, then return the time today
                return scheduledTimeToday
            }
            return nil //TOOD FIX
        case .asNeeded:
            return nil
        }
        
        
    }
    
    //Equatable protocol
    static func == (lhs: Medication, rhs: Medication) -> Bool {
        //TODO: Assign like an ID or smth to that you cant have 2 of the same type
        lhs.id == rhs.id
    }
    
}

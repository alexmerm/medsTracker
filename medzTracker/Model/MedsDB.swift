//
//  MedsDB.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

import Foundation

//THIS IS THE MODEL

struct MedsDB {
    let dateFormatter : DateFormatter
    let dateComponentsFormatter : DateComponentsFormatter
    //DB Initializers
    init() {
        dateFormatter = DateFormatter()
        dateComponentsFormatter = DateComponentsFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateComponentsFormatter.allowedUnits = [.hour, .minute]
        dateComponentsFormatter.zeroFormattingBehavior = .pad
    }
    
    var medications : [Medication] = [] //Store Medications heres
    
    //Returns ID of New Medicaiton
    mutating func addMedication(medName : String, dosage : Int?, dosageUnit : String?, schedule : Medication.Schedule, maxDosage : Int?, reminders : Bool)  -> UUID {
        let med = Medication(name: medName, dosage: dosage, dosageUnit: dosageUnit, schedule: schedule, maxDosage: maxDosage, reminders: reminders, pastDoses: [], dateComponentsFormatter: dateComponentsFormatter, dateFormatter: dateFormatter)
        medications.append(med)
        return med.id
    }
    
    //Gets Medication by UUID
    func getMedicationByUUID(_ uuid : UUID)  -> Medication?{
        for medication in medications {
            if medication.id == uuid {
                return medication
            }
        }
        return nil
    }
    
    //Index only used locally in the db, bc its mutable, thus these are Private Methods
    private func getIndexOfMedication(_ inputMed : Medication)  -> Int? {
        for (index,med) in medications.enumerated() {
            if med == inputMed {
                return index
            }
        }
        return nil
    }
    
    private func getIndexFromUUID(_ uuid : UUID) -> Int? {
        for (index,med) in medications.enumerated(){
            if med.id == uuid {
                return index
            }
        }
        return nil
                
    }
    
    
    //Log a new dosage of medication with UUID uuid
    mutating func logDosage(_ uuid : UUID, time : Date, amount : Int) {
        if let id = getIndexFromUUID(uuid) {
            medications[id].logDosage(time: time, amount: amount)
        }
    }
    
    // MARK: Define Medication and Dosage Structs
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
        static func == (lhs: MedsDB.Medication, rhs: MedsDB.Medication) -> Bool {
            //TODO: Assign like an ID or smth to that you cant have 2 of the same type
            lhs.id == rhs.id
        }
        
    }


}


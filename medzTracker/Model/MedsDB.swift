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
   


}


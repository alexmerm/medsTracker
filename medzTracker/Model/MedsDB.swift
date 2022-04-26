//
//  MedsDB.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

import Foundation

//THIS IS THE MODEL

struct MedsDB : Codable {
    static let dateFormatter : DateFormatter  = DateFormatter()// and this
    static let dateComponentsFormatter : DateComponentsFormatter  =  DateComponentsFormatter()//Need to make this static
    //DB Initializers
    init() {
        //This modidies these static vars when medsDB is created, so it doesn't need to be done again
        MedsDB.dateFormatter.dateStyle = .none
        MedsDB.dateFormatter.timeStyle = .short
        MedsDB.dateComponentsFormatter.allowedUnits = [.hour, .minute]
        MedsDB.dateComponentsFormatter.zeroFormattingBehavior = .pad
    }
    
    static func getDateFormatter() -> DateFormatter {
        return dateFormatter
    }
    static func getDateComponentFormatter() -> DateComponentsFormatter {
        return dateComponentsFormatter
    }
    
    var medications : [Medication] = [] //Store Medications here
    
    //Returns ID of New Medicaiton
    mutating func addMedication(medName : String, dosage : Double?, dosageUnit : Medication.DosageUnit?, schedule : Medication.Schedule, maxDosage : Int?, reminders : Bool)  -> UUID {
        let med = Medication(name: medName, dosage: dosage, dosageUnit: dosageUnit, schedule: schedule, maxDosage: maxDosage, reminders: reminders, pastDoses: [])
        medications.append(med)
        return med.id
    }
    
    mutating func removeMedication(_ uuid : UUID) -> Void {
        let index = getIndexFromUUID(uuid)
        guard let index = index else {
            return
        }
        medications.remove(at: index)
    }
    
    mutating func removeMedicationByIndexSet(_ indexset: IndexSet) {
        medications.remove(atOffsets: indexset)
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
    
    // MARK: Serializing and Deserializing
    ///Gets URL of directory
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("medsDB.data")
    }
    ///@Escaping means that the closure param will outlive the func its passed into
    ///Loads the Data
    static func load(completion: @escaping (Result<MedsDB,Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL() //the URL of the medsDB DataStore file
                guard let file = try? FileHandle(forReadingFrom: fileURL) else { //try to load from the file, if it doesn't exist (aka its the initial opening of the app)...return a success with a new Medicaition DB
                    DispatchQueue.main.async {
                        completion(.success(MedsDB()))
                    }
                    return
                }
                //but if there was an file, we need to decode it
                let medsDB = try JSONDecoder().decode(MedsDB.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(medsDB)) //and return it successfully if it succeeds
                }
            } catch {
                //and id it fails, return the erorr
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    ///Saves the data
    ///Completion returns either the num of saved meds or an error
    static func save(medsDB: MedsDB, completion: @escaping (Result<Int,Error>)-> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(medsDB)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(medsDB.medications.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

}


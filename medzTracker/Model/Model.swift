//
//  MedsDB.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

import Foundation

//THIS IS THE MODEL

struct Model : Codable {
    //DB Initializers
    init() {
        self.setupDateFormatters()
    }
    
    init(from: [Medication]) {
        self.medications = from
        self.setupDateFormatters()
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
    
    ///get Medications from IndexSet
    func getMedicationsByIndexSet(_ indexset: IndexSet) -> [Medication] {
        var result : [Medication] = []
        indexset.forEach {index in
            result.append(medications[index])
        }
        return result
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
    mutating func logDosage(_ uuid : UUID, time : Date, amount : Double?) {
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
    ///MARK: Changing this to  saving [medication] so i can pass scheduler in.... or do i even need to
    ///@Escaping means that the closure param will outlive the func its passed into
    ///Loads the Data
    static func load(completion: @escaping (Result<Model,Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL() //the URL of the medsDB DataStore file
                guard let file = try? FileHandle(forReadingFrom: fileURL) else { //try to load from the file, if it doesn't exist (aka its the initial opening of the app)...return a success with a new Medicaition DB
                    DispatchQueue.main.async {
                        completion(.success(Model()))
                    }
                    return
                }
                //but if there was an file, we need to decode it
                let medsArray = try JSONDecoder().decode([Medication].self, from: file.availableData)
                let medsDB = Model(from: medsArray)
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
    static func save(medsDB: Model, completion: @escaping (Result<Int,Error>)-> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(medsDB.medications)
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
    
    //MARK: DateFormatters
    static let dateFormatter : DateFormatter  = DateFormatter()// and this
    static let dateComponentsFormatter : DateComponentsFormatter  =  DateComponentsFormatter()//Need to make this static
    static let relativeDateFormatter : DateFormatter = DateFormatter()
    
    func setupDateFormatters() {
        //This modidies these static vars when medsDB is created, so it doesn't need to be done again
        Model.dateFormatter.dateStyle = .none
        Model.dateFormatter.timeStyle = .short
        Model.dateComponentsFormatter.allowedUnits = [.hour, .minute]
        Model.dateComponentsFormatter.zeroFormattingBehavior = .pad
        Model.relativeDateFormatter.dateStyle = .short
        Model.relativeDateFormatter.timeStyle = .short
        Model.relativeDateFormatter.doesRelativeDateFormatting = true
    }
    
    static func getDateFormatter() -> DateFormatter {
        return dateFormatter
    }
    static func getDateComponentsFormatter() -> DateComponentsFormatter {
        return dateComponentsFormatter
    }

}


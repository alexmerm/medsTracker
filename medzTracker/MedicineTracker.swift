//
//  MedicineTracker.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

//THIS IS THE VIEWMODEL
import Foundation

class MedicineTracker : ObservableObject { // We Serialize+Deserialize the entire MedsDB Class, even tho we don't have to 

    
    //private(set) means other things can see the model but can't change it
    //Creates the model
    @Published private(set) var model : MedsDB = MedsDB()
    //non-static function to load data
    func loadData() {
        MedicineTracker.load(completion: { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let medsDB):
                self.model = medsDB
            }
        })
    }

    func saveData() {
        MedicineTracker.save(medsDB: model) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    
    //TODO: Put all of these into Model
    ///Create the Data store
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
    
    
    
    ///These Methods are for intents from the view to modify or access the model

    //Add Medication to model
    func addMedicationToModel(medName : String, dosage : Double?, dosageUnit : Medication.DosageUnit?, schedule : Medication.Schedule, maxDosage : Int?, reminders : Bool) -> UUID {
        let newMedID =  model.addMedication(medName: medName, dosage: dosage, dosageUnit: dosageUnit, schedule: schedule, maxDosage: maxDosage, reminders: reminders)
        self.saveData()
        return newMedID
    }
    
    func getMedicationByUUID(_ uuid : UUID)  -> Medication?{
        model.getMedicationByUUID(uuid)
    }
    
    func logDosage(uuid : UUID, time : Date, amount : Int) {
        model.logDosage(uuid, time: time, amount: amount)
    }
    
    var meds: [Medication] {
        return model.medications
    }
    
    
    func insertDummyData() {
        let id1 = self.addMedicationToModel(medName: "Adderall IR", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)

        let id2 = self.addMedicationToModel(medName: "Claratin", dosage: nil, dosageUnit: nil, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id2, time: Date() - 400, amount: 10)
        let id3 = self.addMedicationToModel(medName: "Sudafed", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id3, time: Date() - 200, amount: 10)
    }
    

    
}

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
    @Published private(set) var model : MedsDB = MedsDB() //this shouldn't init here but for now it does
    //non-static function to load data
    func loadData() {
        MedsDB.load(completion: { result in
            switch result {
            case .failure(let error):
                //for now, lets just throw an error and replace the data
                debugPrint(error.localizedDescription)
                //fatalError(error.localizedDescription)
                self.model = MedsDB()
                self.saveData()
            case .success(let medsDB):
                self.model = medsDB
            }
        })
    }

    func saveData() {
        debugPrint("saving Data")
        MedsDB.save(medsDB: model) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
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
    func removeMedication(_ uuid : UUID) -> Void {
        model.removeMedication(uuid)
    }
    
    func removeMedicationsByIndexSet(indexSet: IndexSet) {
        model.removeMedicationByIndexSet(indexSet)
    }
    
    
    func insertDummyData() {
        let _ = self.addMedicationToModel(medName: "Adderall IR", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)

        let id2 = self.addMedicationToModel(medName: "Claratin", dosage: nil, dosageUnit: nil, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id2, time: Date() - 400, amount: 10)
        let id3 = self.addMedicationToModel(medName: "Sudafed", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id3, time: Date() - 200, amount: 10)
    }
    

    
}

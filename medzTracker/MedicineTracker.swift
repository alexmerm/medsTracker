//
//  MedicineTracker.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

//THIS IS THE VIEWMODEL
import Foundation



class MedicineTracker : ObservableObject {
    internal init() {
        self.scheduler = Scheduler()
        self.model = Model()
        self.loadData()
    }
    
    // We Serialize+Deserialize the entire MedsDB Class, even tho we don't have to

    
    //private(set) means other things can see the model but can't change it
    //Creates the model
    @Published private(set) var model : Model  //this shouldn't init here but for now it does
    private(set)var scheduler : Scheduler
    
    
    //non-static function to load data
    func loadData() {
        debugPrint("Loading Data")
        Model.load(completion: { [self] result in
            switch result {
            case .failure(let error):
                //for now, lets just throw an error and replace the data
                debugPrint(error.localizedDescription)
                //fatalError(error.localizedDescription)
                self.model = Model()
                self.saveData()
            case .success(let medsDB):
                self.model = medsDB
            }
            
            self.scheduler.getNotificationPermissions()
            self.scheduler.loadExistingNotificationsFromSystemAndScheduleAll(medications: self.meds)
        })
    }

    func saveData() {
        debugPrint("saving Data")
        Model.save(medsDB: model) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    

    

    
    func updateMedNotificationsByUUID(medID: UUID) -> UUID? {
        if let med = getMedicationByUUID(medID) {
            return scheduler.updateMedicationNotications(medication: med)
        }
        return nil
    }
    
    
    
    
    ///These Methods are for intents from the view to modify or access the model

    //Add Medication to model
    func addMedicationToModel(medName : String, dosage : Double?, dosageUnit : Medication.DosageUnit?, schedule : Medication.Schedule, maxDosage : Int?, reminders : Bool) -> UUID {
        let newMedID =  model.addMedication(medName: medName, dosage: dosage, dosageUnit: dosageUnit, schedule: schedule, maxDosage: maxDosage, reminders: reminders)
        self.saveData()
        let _ = updateMedNotificationsByUUID(medID: newMedID)
        return newMedID
    }
    
    func getMedicationByUUID(_ uuid : UUID)  -> Medication?{
        model.getMedicationByUUID(uuid)
    }
    
    func logDosage(uuid : UUID, time : Date, amount : Double?) {
        model.logDosage(uuid, time: time, amount: amount)
        let _ = updateMedNotificationsByUUID(medID: uuid)
        self.saveData()
    }
    
    var meds: [Medication] {
        return model.medications
    }
    func removeMedication(_ uuid : UUID) -> Void {
        if let med = getMedicationByUUID(uuid) {
            scheduler.removeMedicationsNotifications(medication: med)
        }
        model.removeMedication(uuid)
    }
    
    func removeMedicationsByIndexSet(indexSet: IndexSet) {
        for med in model.getMedicationsByIndexSet(indexSet) {
            scheduler.removeMedicationsNotifications(medication: med)
        }
        model.removeMedicationByIndexSet(indexSet)
    }
    
    
    func insertDummyData() {
        let id1 = self.addMedicationToModel(medName: "Adderall IR", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id1, time: Date() - 400, amount: 10)
        self.logDosage(uuid: id1, time: Date() - 400 - (60 * 60 * 4), amount: 10)

        let id2 = self.addMedicationToModel(medName: "Claratin", dosage: nil, dosageUnit: nil, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id2, time: Date() - 400, amount: 10)
        let id3 = self.addMedicationToModel(medName: "Sudafed", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id3, time: Date() - 200, amount: 10)
        
        let id4 = self.addMedicationToModel(medName: "Cymbalta", dosage: 60, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.specificTime(hour: 9, minute: 30), maxDosage: 60, reminders: true)
        self.logDosage(uuid: id4, time: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!, amount: 60)
        self.logDosage(uuid: id4, time: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date() - TimeInterval(60 * 60 * 24))!, amount: 60)
        
        let _ = self.addMedicationToModel(medName: "Xanax", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.asNeeded, maxDosage: nil, reminders: true)
        
        let id5 = self.addMedicationToModel(medName: "EveryMin", dosage: 10, dosageUnit: .mg, schedule: .intervalSchedule(interval: 60), maxDosage: nil, reminders: true)
        self.logDosage(uuid: id5, time: Date() - 180, amount: 10)
        
        _ = self.addMedicationToModel(medName: "NextMin", dosage: 10, dosageUnit: .mg, schedule: .specificTime(hour: Calendar.current.component(.hour, from: .now + 60), minute: Calendar.current.component(.minute, from: .now + 60)), maxDosage: nil, reminders: true)
        
        let id6 = self.addMedicationToModel(medName: "Overdue", dosage: 10, dosageUnit: .mg, schedule: .specificTime(hour: Calendar.current.component(.hour, from: .now - 60), minute: Calendar.current.component(.minute, from: .now - 60)), maxDosage: nil, reminders: true)
        self.model.getMedicationByUUID(id6)?.modificationTime = Date() - 120
        self.logDosage(uuid: id6, time: Date.now - (60 * 60 * 24 + 60) , amount: 10)


    }
    

    
}

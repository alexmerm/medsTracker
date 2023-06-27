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
    
    //Creates the model
    @Published private(set) var model : Model
    private(set)var scheduler : Scheduler
    
    
    //non-static function to load data and setup notifications
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

    ///Save data
    func saveData() {
        debugPrint("saving Data")
        Model.save(medsDB: model) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }

    //Trigger Notification Updates for a Medication
    func updateMedNotificationsByUUID(medID: UUID) -> UUID? {
        if let med = getMedicationByUUID(medID) {
            return scheduler.updateMedicationNotications(medication: med)
        }
        return nil
    }
    
    
    ///Add Medication to model
    func addMedicationToModel(medName : String, dosage : Double?, dosageUnit : Medication.DosageUnit?, schedule : Medication.Schedule, maxDosage : Int?, reminders : Bool) -> UUID {
        let newMedID =  model.addMedication(medName: medName, dosage: dosage, dosageUnit: dosageUnit, schedule: schedule, maxDosage: maxDosage, reminders: reminders)
        self.saveData()
        let _ = updateMedNotificationsByUUID(medID: newMedID)
        return newMedID
    }
    
    ///Access function for Medications
    func getMedicationByUUID(_ uuid : UUID)  -> Medication?{
        model.getMedicationByUUID(uuid)
    }
    
    ///Log Dosage of Medication
    func logDosage(uuid : UUID, time : Date, amount : Double?) {
        model.logDosage(uuid, time: time, amount: amount)
        let _ = updateMedNotificationsByUUID(medID: uuid)
        self.saveData()
    }
    
    ///Access Array of Medications
    var meds: [Medication] {
        return model.medications
    }
    
    ///Remove Medication by ID
    func removeMedication(_ uuid : UUID) -> Void {
        if let med = getMedicationByUUID(uuid) {
            scheduler.removeMedicationsNotifications(medication: med)
        }
        model.removeMedication(uuid)
    }
    
    ///Remove Medication By Index Set
    func removeMedicationsByIndexSet(indexSet: IndexSet) {
        for med in model.getMedicationsByIndexSet(indexSet) {
            scheduler.removeMedicationsNotifications(medication: med)
        }
        model.removeMedicationByIndexSet(indexSet)
    }
    
    
    ///Inserts Data for Testing Purposes
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
    
    ///Inserts data for Demo Purposes
    func insertDemoData() {
        let tylenol = self.addMedicationToModel(medName: "Tylenol", dosage: 2, dosageUnit: .pills, schedule: .intervalSchedule(interval: 4 * 60 * 60), maxDosage: nil, reminders: true)
        let todayAt1115 = Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: Date())!
        self.logDosage(uuid: tylenol, time: todayAt1115, amount: 2)
        
        let cymbalta = self.addMedicationToModel(medName: "Cymbalta", dosage: 60, dosageUnit: .mg, schedule: .specificTime(hour: 9, minute: 30), maxDosage: 10, reminders: true)
        for num in 0...10 {
            let day = Calendar.current.date(byAdding: .day, value: -1 * num, to: Date())!
            let at930 = Calendar.current.date(bySettingHour: 9, minute:30, second: Int.random(in: 0...59), of: day)!
            let added = Calendar.current.date(byAdding: .minute, value: Int.random(in: 0...45), to: at930)!
            self.logDosage(uuid: cymbalta, time: added, amount: 60)
        }
        let melatonin = self.addMedicationToModel(medName: "Melatonin", dosage: 2, dosageUnit: .other(unit: "gummies"), schedule: .specificTime(hour: 23, minute: 30), maxDosage: 1, reminders: true)
        for num in 1...7 {
            let day = Calendar.current.date(byAdding: .day, value: -1 * num, to: Date())!
            let at930 = Calendar.current.date(bySettingHour: 23 , minute:15, second: Int.random(in: 0...44), of: day)!
            let added = Calendar.current.date(byAdding: .minute, value: Int.random(in: 0...44), to: at930)!
            self.logDosage(uuid: melatonin, time: added, amount: 60)
        }

    }
    

    
}

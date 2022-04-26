//
//  AddMedicineView.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/6/22.
//

import SwiftUI
import Combine

struct AddMedicineView: View {
    @ObservedObject var viewModel : MedicineTracker
    @Binding var isOnAddingScreen : Bool
    @State var errorIsDisplayed : Bool = false
    @State var errorText = ""
    
    //Medication Variables
    @State var medication_name : String = ""
    @State var dosage_string : String = ""
    @State var dosage_unit: Medication.DosageUnit?
    @State var customDosageUnit = INITIAL_CUSTOM_UNIT
    @State var isAddingCustomUnit = false
    enum ScheduleType : Hashable, Equatable {
        case intervalSchedule
        case specificTime
        case asNeeded
    }
    @State var scheduleType : ScheduleType? = nil
    
    //Specific time variabels
    @State var specificTime : Date = .now
    //Interval variabels
    @State var interval_hour : Int = 0
    @State var interval_minute : Int = 0
    
    @State var wantReminders : Bool = true
    
    
    
    static let INITIAL_CUSTOM_UNIT = "Custom"
    //Vars for interval Time selection
    static let hours = [Int](0..<23)
    static let minutes = [Int](0..<59)
    
    var body: some View {
        ZStack {
            
            //Form Actually Displayed
            Form {
                Section(header: Text("Medication Info")) {
                    HStack{
                        Text("Medication Name")
                        TextField("Required", text: $medication_name).disableAutocorrection(true)
                    }
                    HStack{
                        Text("Dosage")
                        TextField("amt", text: $dosage_string).keyboardType(.decimalPad)
                        //Special code to make sure it actually just has numbers
                            .onReceive(Just(dosage_string)) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.dosage_string = filtered
                                }
                            }
                        
                        Picker("Unit", selection: $dosage_unit) {
                            ForEach(Medication.DosageUnit.allCases, id:
                                        \.self) { unit in
                                Text(unit.description).tag(Optional(unit))
                            }
                            
                            Text(customDosageUnit).tag(Optional(Medication.DosageUnit.other(unit: "TEMPCUSTOMUNIT"))) //This Val isn't actually used, we replace it with a diff DosageUnit whnen submitting
                        }
                        //Whenever something is selected
                        .onChange(of: self.dosage_unit) { newunit in
                            //If something was actually selected (not null)
                            if let unit = newunit {
                                //if a custom unit was selected
                                if case Medication.DosageUnit.other(unit: _ ) = unit{
                                    //if the custom Unit is still set to the original unit, blank it
                                    if customDosageUnit == AddMedicineView.INITIAL_CUSTOM_UNIT {
                                        customDosageUnit = ""
                                        print("Blanking CustomUnit")
                                    }
                                    //Delay by 0.75 bc of some weird bug
                                    //then load the custom unit screen
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                        self.isAddingCustomUnit.toggle()
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
                Section(header: Text("Schedule")) {
                    VStack(alignment: .leading) {
                        Text("Schedule Type").multilineTextAlignment(.leading)
                        Picker("ScheduleType", selection: $scheduleType) {
                            Text("As Needed").tag(Optional(ScheduleType.asNeeded))
                            Text("Interval").tag(Optional(ScheduleType.intervalSchedule))
                            Text("Specific Time").tag(Optional(ScheduleType.specificTime))
                        }.pickerStyle(.segmented)
                    }
                    switch scheduleType {
                    case .asNeeded:
                        Text("No Further Detail Needed")
                    case .specificTime:
                        DatePicker("Time",selection: $specificTime, displayedComponents:.hourAndMinute).datePickerStyle(.compact)
                    case .intervalSchedule:
                        HStack() {
                            Text("Interval: ")
                                .fontWeight(.bold)
                            Picker("Hours",selection: $interval_hour) {
                                ForEach(AddMedicineView.hours, id: \.self) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }.pickerStyle(.menu)
                            Text(":")
                            
                            Picker("Minutes", selection: $interval_minute) {
                                ForEach(AddMedicineView.minutes,id: \.self) { minute in
                                    Text("\(minute) m").tag(minute)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    case.none:
                        Text("Please select a schedule type")
                    }
                    
                }
                if scheduleType == .specificTime || scheduleType == .intervalSchedule {
                    Section(header: Text("Reminders")) {
                        Toggle("Reminders?", isOn: $wantReminders)
                    }
                }
                
            }.navigationTitle("Add a Medication")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: self.addMedication) {
                            Text("Save")
                        }.alert(isPresented: $errorIsDisplayed) {
                            Alert(title:
                                    Text(errorText)
                            )
                        }
                    }
                }
            //Invisible Link to move to CustomUnit Page
            NavigationLink(destination:  customTextFieldView(customDosageUnit: $customDosageUnit, isAddingCustomUnit: $isAddingCustomUnit), isActive: $isAddingCustomUnit, label:{ Text("NavigationLink")}).hidden().disabled(true)
        }
    }
    enum VerifyResult : Equatable {
        case success
        case failure(error: String)
    }
    func verifyMedication() -> VerifyResult {
        guard medication_name != "" else {
            return .failure(error: "Medication name must be set")
        }
        //if a dosage amt is selected, a unit must also be selected
        if dosage_string != "" {
            //Verify a unit is selected
            //Shoould prob throw an alert if not selected
            guard let _ = dosage_unit else {
                return .failure(error: "Must select a dosage unit")
            }
        }
        guard let scheduleType = scheduleType else {
            return .failure(error: "Must select a schedule type")
        }
        //now scheduleType is no longer optional
        switch scheduleType {
        case .intervalSchedule:
            guard (interval_minute != 0 || interval_hour != 0) else {
                return .failure(error: "Interval cannot be 0 ")
            }
            return .success
        case .specificTime,.asNeeded:
            //nothing to check for specifictime
            return .success
        }
    }
    func addMedication() {
        let result = verifyMedication()
        guard result == VerifyResult.success else {
            switch result {
            case .success:
                print("Woo it worked, but this will never exec ")
            case .failure(let error):
                print("Error!! \(error)") //and throw some alert
                errorText = error
                errorIsDisplayed = true
            }
            return
        }
        //if other, make dosage unit with correct string
        if let unit = dosage_unit {
            if case Medication.DosageUnit.other(unit: _ ) = unit{
                self.dosage_unit = Medication.DosageUnit.other(unit: customDosageUnit)
            }
        }
        //Create schedule unit
        guard let scheduleType = scheduleType else {
            return //this will never flop return bc its issues
        }
        let schedule : Medication.Schedule
        switch scheduleType {
        case .asNeeded:
            schedule = Medication.Schedule.asNeeded
        case .intervalSchedule:
            let interval = TimeInterval(interval_hour * 3600 + interval_minute * 60)
            schedule = Medication.Schedule.intervalSchedule(interval: interval)
        case .specificTime:
            schedule = Medication.Schedule.specificTime(time: specificTime)
        }
        //actually add to DB
        let _ = viewModel.addMedicationToModel(medName: medication_name, dosage: Double(dosage_string), dosageUnit: dosage_unit, schedule: schedule, maxDosage: nil, reminders: wantReminders)
        //Need to make it leave this page lmao
        isOnAddingScreen = false
        
    }
}

struct customTextFieldView : View  {
    @Binding var customDosageUnit : String
    @Binding var isAddingCustomUnit : Bool
    @FocusState var isFocusedOnTextField : Bool
    var body: some View {
        Form {
            HStack{
                Text("Enter Unit :")
                TextField("Custom Unit", text: $customDosageUnit).focused($isFocusedOnTextField)
                    .disableAutocorrection(true)
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocusedOnTextField = true
                }
            }
            .navigationBarBackButtonHidden(true)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.isAddingCustomUnit.toggle()})
                        { Text("save")}
                    }
                })
        }.onSubmit {
            self.isAddingCustomUnit.toggle()
        }
    }
}


struct AddMedicineView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MedicineTracker()
        //tracker.insertDummyData()
        Group {
            AddMedicineView(viewModel: viewModel,isOnAddingScreen: Binding.constant(true), scheduleType: .intervalSchedule)
            //            AddMedicineView(scheduleType: .specificTime)
            //            AddMedicineView(scheduleType: .asNeeded)
            //                        AddMedicineView()
        }
    }
}

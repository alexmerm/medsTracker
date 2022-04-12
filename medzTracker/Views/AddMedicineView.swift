//
//  AddMedicineView.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/6/22.
//

import SwiftUI

struct AddMedicineView: View {
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
    @State var intervalTime : TimeInterval = .zero
    @State var specificTime : Date = .now
    
    @State var interval_hour : Int? = nil
    @State var interval_minute : Int? = nil
    
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
                        TextField("Required", text: $medication_name)
                    }
                    HStack{
                        Text("Dosage")
                        TextField("amt", text: $dosage_string).keyboardType(.numberPad)
                        
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
                            Text("Inteval").tag(Optional(ScheduleType.intervalSchedule))
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
                        }
                    }
                }
            //Invisible Link to move to CustomUnit Page
            NavigationLink(destination:  customTextFieldView(customDosageUnit: $customDosageUnit, isAddingCustomUnit: $isAddingCustomUnit), isActive: $isAddingCustomUnit, label:{ Text("NavigationLink")}).hidden().disabled(true)
        }
    }
    func verifyMedication() -> Bool {
        return true
    }
    func addMedication() {
        if verifyMedication() {
            print("we did it")
        }
    }
}

struct customTextFieldView : View  {
    @Binding var customDosageUnit : String
    @Binding var isAddingCustomUnit : Bool
    var body: some View {
        Form {
            HStack{
                Text("Enter Unit :")
                TextField("Custom Unit", text: $customDosageUnit).disableAutocorrection(true)
                
                
            }.navigationBarBackButtonHidden(true)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { self.isAddingCustomUnit.toggle()})
                        { Text("save")}
                    }
                })
        }
    }
}


struct AddMedicineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddMedicineView(scheduleType: .intervalSchedule)
            //            AddMedicineView(scheduleType: .specificTime)
            //            AddMedicineView(scheduleType: .asNeeded)
            //                        AddMedicineView()
        }
    }
}

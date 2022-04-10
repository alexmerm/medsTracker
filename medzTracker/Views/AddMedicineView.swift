//
//  AddMedicineView.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/6/22.
//

import SwiftUI

struct AddMedicineView: View {
    @State private var medication_name : String = ""
    @State private var dosage_string : String = ""
    @State private var dosage_unit: Medication.DosageUnit?
    static let INITIAL_CUSTOM_UNIT = "Custom"
    @State var customDosageUnit = INITIAL_CUSTOM_UNIT
    @State var isAddingCustomUnit = false
    enum ScheduleType : Hashable, Equatable {
        case intervalSchedule
        case specificTime
        case asNeeded
    }
    @State internal var scheduleType : ScheduleType? = nil
    @State private var intervalTime : TimeInterval = .zero
    @State var specificTime : Date = .now
    
    @State var interval_hour : Int? = nil
    @State var interval_minute : Int? = nil
    
    @State var wantReminders : Bool = true
    
    
    //Vars for interval Time selection
    let hours = [Int](0..<23)
    let minutes = [Int](0..<59)
    
    var body: some View {
        
        
        return Form {
            Section(header: Text("Medication Info")) {
                HStack{
                    Text("Medication Name")
                    TextField("Required", text: $medication_name)
                }
                HStack{
                    Text("Dosage")
                    TextField("amt", text: $dosage_string).keyboardType(.numberPad)
                    //Picker dosage unitp
                    //TextField("unit", text: $dosage_unit)
                    //Put navigationLink into ZStack with the picker
                    ZStack {
                        NavigationLink(destination:  customTextFieldView(customDosageUnit: $customDosageUnit, isAddingCustomUnit: $isAddingCustomUnit), isActive: $isAddingCustomUnit, label:{ Text("NavigationLink")}).hidden().disabled(true)
                        
                        Picker("Unit", selection: $dosage_unit) {
                            ForEach(Medication.DosageUnit.allCases, id:
                                        \.self) { unit in
                                Text(unit.description).tag(Optional(unit))
                            }
                            Text(customDosageUnit).tag(Optional(Medication.DosageUnit.other(unit: "TEMPCUSTOMUNIT")))
                        }
                        //Whenever something is selected
                        .onChange(of: self.dosage_unit) { newunit in
                            //If something was actually selected (not null)
                            if let unit = newunit {
                                //if a custom unit was selected
                                if case Medication.DosageUnit.other(unit: _ ) = unit{
                                    print("currentString: \(customDosageUnit)")
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
                    Text("asNeeded")
                case .specificTime:
                    Text("SpecificTime")
                    DatePicker("Time",selection: $specificTime, displayedComponents:.hourAndMinute).datePickerStyle(.compact)
                    
                case .intervalSchedule:
                    Text("intervalSchedule")
                    
                    HStack() {
                        Text("Interval: ")
                            .fontWeight(.bold)
                        Picker("Hours",selection: $interval_hour) {
                            ForEach(self.hours, id: \.self) { hour in
                                Text("\(hour) h").tag(hour)
                            }
                        }.pickerStyle(.menu)
                        Text(":")
                        
                        Picker("Minutes", selection: $interval_minute) {
                            ForEach(self.minutes,id: \.self) { minute in
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
            //            AddMedicineView()
        }
    }
}

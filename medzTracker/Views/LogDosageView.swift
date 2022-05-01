//
//  LogDosageView.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/29/22.
//

import SwiftUI

struct LogDosageView: View {
    enum LogType {
        case log
        case remindMe
    }
    
    @State var viewModel : MedicineTracker
    @State var medication : Medication
    
    @State var timeTaken : Date
    @State var logType : LogType = .log
    @State var fromNotification = false
    @Binding var isOnLogView : Bool
    
    var body: some View {
        
        VStack {
            Text("Did you just take the \(medication.name)?")
            
            HStack {
                ResponseButton(action: {
                    print("no")
                    logType = .remindMe
                }, text: "No, Remind Me", color: .red)
                ResponseButton(action: {
                    logType = .log
                    print("yes")
                }, text: "Yes, Log It!", color: .green)
            }
            
            if case .log = logType {
                Form {
                    Text("What time did you take it?")
                    DatePicker("", selection: $timeTaken, displayedComponents: .hourAndMinute).datePickerStyle(.wheel)
                }
                Button {
                    print("submit")
                    viewModel.logDosage(uuid: medication.id, time: timeTaken, amount: medication.dosage)
                    isOnLogView = false
                } label: {
                    Text("Submit")
                }
            }

        }
    }
    
}


struct ResponseButton : View {
    let action : ()->Void
    let text : String
    let color : Color
    var body: some View {
        Button(action: {
            action()
        }, label: {
            //            Image(systemName: "circle")
            //                .resizable()
            //                .scaledToFit()
            //                .overlay(Text(text)
            //                    .font(.title)
            //                    .multilineTextAlignment(.center)
            //                ).foregroundColor(color)
            Circle().stroke(color,lineWidth: 3)
                .overlay(
                    Text(text).foregroundColor(.black)
                        .font(.title2)
                        .multilineTextAlignment(.center))

        }).padding()
    }
    
}

struct LogDosageView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        let tracker = MedicineTracker()
        tracker.insertDummyData()
        return LogDosageView(viewModel: tracker, medication: tracker.meds[0], timeTaken: Date(), isOnLogView: Binding.constant(true))
    }
}

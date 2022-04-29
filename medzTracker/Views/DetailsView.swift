//
//  DetailsView.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/6/22.
//

import SwiftUI

struct DetailsView: View {
    var viewModel : MedicineTracker
    var medication :Medication //could in theory just pass in an ID, but not bc this is simpler for testing purposes
    var body: some View {
        
        VStack(alignment: .leading) {
            //Dosage Amount
            if let readableDosage = medication.readableDosage {
                Text("**Dosage** : \(readableDosage)").font(.subheadline)
                
            }
            Divider()
            //Schedule
            
            if medication.schedule.isScheduled() {
                Section {
                    Text("Next Dosage").font(.title2)
                    Text(medication.getNextDosageTime()!.relativeFormattedString).padding(.leading)
                }
                Divider()
                Section {
                    Text("Schedule").font(.title2)
                    Text(medication.schedule.readableSchedule!).padding(.leading)
                }
                

                Divider()
                
                
            }
            
            
            Section {
                Text("Previous Doses").font(.title2)
                if medication.pastDoses.isEmpty {
                    Text("You haven't taken this yet").padding(.leading)
                }
                //"Else"
                List {
                    ForEach(medication.pastDoses.reversed().prefix(10), id: \.self) { dosage in
                        Text("\(dosage.relativeTimeString)")
                    }
                }.listStyle(.inset).listRowSeparator(.hidden)
            }

            Divider()
            
            Spacer()
        }.padding()
            .navigationBarTitle(medication.name)
    }
    
    
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let tracker = MedicineTracker()
        tracker.insertDummyData()
        return Group{
            ForEach(tracker.meds) { med in
                NavigationView {
                    DetailsView(viewModel: tracker, medication: med)
                }
                
            }
        }
    }
}

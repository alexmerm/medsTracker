//
//  DetailsView.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/6/22.
//

import SwiftUI

struct DetailsView: View {
    var viewModel : MedicineTracker
    @StateObject var medication :Medication //could in theory just pass in an ID, but not bc this is simpler for testing purposes
    @State var isOnLogView : Bool = false
    var body: some View {
        
        VStack(alignment: .leading) {
            //Dosage Amount
            if let readableDosage = medication.readableDosage {
                Text("**Dosage** : \(readableDosage)").font(.subheadline)
                
            }
            Divider()
            //Schedule
            
            if medication.schedule.isScheduled() {
                if let nextDosageTime = medication.getNextDosageTime() {
                    Section {
                        
                        Text("Next Dosage").font(.title2)
                        Text(nextDosageTime.relativeFormattedString).padding(.leading)
                    }
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
            }.onAppear {
                print("numDoses: \(medication.pastDoses.count)")
            }

            Divider()
            
            Spacer()
        }.padding()
            .navigationBarTitle(medication.name)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:
                                    LogDosageView(viewModel: viewModel, medication: medication,
                                                  timeTaken: Date(),
                                                  isOnLogView: $isOnLogView),
                                   isActive: $isOnLogView,
                                   label: {
                        Label("Log", systemImage: "circle")
                    })
                    

                }
            })
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

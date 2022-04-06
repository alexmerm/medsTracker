//
//  ContentView.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

//View Class

import SwiftUI
import CoreData



struct ContentView: View {
    
    @ObservedObject var viewModel : MedicineTracker //ViewModel will be passed in

    // MARK: Actual View
    var body: some View {
        
        NavigationView {
                            
                List(viewModel.meds) { med in
                    NavigationLink {
                        DetailsView(medicine: med)
                    } label: {
                        MedicationRow(medicine: med)
                    }
                        
                }
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading) {
                            HStack {
                                Image(systemName: "pills")
                                Text("MedsTracker")
                            }.font(.title)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.insertDummyData()
                            } label: {
                                Image(systemName: "plus.circle")
                            }.font(.title2)
                        }
                    })
            }

        }
    
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

// MARK: Medication Row Definition
struct MedicationRow : View {
    //init from medication object
    ///lowkey I think *this* is the stuff that should be done in viewController but whatenvs
    init(medicine inputMed : MedsDB.Medication) {
        medName = inputMed.name
        medDosage = inputMed.readableDosage
        timeDelta = inputMed.getLatestDosage()?.timeSinceDosageString
        timeOfLastDosage = inputMed.getLatestDosage()?.timeString
    }
    //Default Init
    init(medName: String, medDosage: String?, timeSinceDosage: String?, timeOfLastDosage : String?) {
        self.medName = medName
        self.medDosage = medDosage
        self.timeDelta = timeSinceDosage
        self.timeOfLastDosage = timeOfLastDosage
    }
    
    var medName : String
    var medDosage : String?
    var timeDelta : String?
    var timeOfLastDosage : String?
    var body : some View {
        VStack{
            HStack {
                Text(medName).font(.title2
                )
                Spacer()
                Label(timeDelta ?? "N/A", systemImage: "timer")
            }
            if medDosage != nil || timeOfLastDosage != nil{
                HStack{
                    if let medDosage = medDosage {
                        Text(medDosage)
                            .padding(.leading)
                    }
                    Spacer()
                    if let timeOfLastDosage = timeOfLastDosage {
                        Text("(\(timeOfLastDosage))")
                    }
                }.font(.footnote)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let tracker = MedicineTracker()
        tracker.insertDummyData()
        
        
    
        return ContentView(viewModel: tracker).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

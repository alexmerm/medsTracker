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
                Text("Dosage : \(readableDosage)").font(.caption)
                
            }
            if medication.schedule != Medication.Schedule.asNeeded {
                VStack{
                    let readableSchedule = medication.readableSchedule!
                    Text("Schedule:").font(.title2)
                    switch medication.schedule {
                    case .asNeeded:
                        Text("nada")
                    case .intervalSchedule(interval: _),.specificTime(time:  _):
                        Text(readableSchedule)
                    }
                }
            }

            
            HStack {
                
                Spacer()
            }
            if let dosage = medication.getLatestDosage(){
                Text(dosage.timeString)
            }
                
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

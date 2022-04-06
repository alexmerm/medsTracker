//
//  DetailsView.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/6/22.
//

import SwiftUI

struct DetailsView: View {
    var medicine :MedsDB.Medication
    var body: some View {
        Text("Hello, \(medicine.name)!")
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let tracker = MedicineTracker()
        tracker.insertDummyData()
        return Group{
        ForEach(tracker.meds) { med in
            DetailsView(medicine: med)
            
        }
        }
    }
}

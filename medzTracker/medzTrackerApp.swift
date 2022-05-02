//
//  medzTrackerApp.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

import SwiftUI

@main
struct medzTrackerApp: App {
    
    //Initialize ViewModel
    let tracker  = MedicineTracker()
    var body: some Scene {
        WindowGroup {
            //Put viewmodel into view
            ContentView(viewModel: tracker)
        }
    }
}

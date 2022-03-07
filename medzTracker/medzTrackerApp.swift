//
//  medzTrackerApp.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

import SwiftUI

@main
struct medzTrackerApp: App {
    let persistenceController = PersistenceController.shared
    
    //Initialize ViewModel
    let tracker  = MedicineTracker()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: tracker)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

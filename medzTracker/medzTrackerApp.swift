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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

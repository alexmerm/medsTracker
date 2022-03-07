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
//    CoreData things
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    
    @ObservedObject var viewModel : MedicineTracker //ViewModel will be passed in

    // MARK: Actual View
    var body: some View {
        
        VStack {
            //Title Bar
            HStack(){
                Spacer()
                //TODO: Figure out how to make this title actually centered
                Image(systemName: "pills").font(.title)
                Text("MedsTracker")
                Spacer()
                Button {
                    viewModel.insertDummyData()
                    //TODO: IMPLEMENT THIS
                } label: {
                    Image(systemName: "plus.circle")
                }.font(.title)
                    .padding(.trailing)
            }.font(.largeTitle)
            Spacer()
            //Medicine List
            ZStack{
                //Background of List
                Color(UIColor.secondarySystemBackground)
                //Text Behind List
                VStack {
                    Image(systemName: "pills")
                    Text("MedsTracker")
                    Spacer()
                }.padding(30)
                    .font(.largeTitle)
                //Actual List
                List(viewModel.meds) { med in
                    MedicationRowView(medicine: med)
                }
                    .onAppear {
                        // Set the default background to clear
                        UITableView.appearance().backgroundColor = .clear
                    }
            }
            //TODO: Navigation Bar
        }
    }
//    // MARK: CoreData Template Funcs
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

// MARK: Medication Row Definition
struct MedicationRowView : View {
    //init from medication object
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

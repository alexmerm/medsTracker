//
//  ContentView.swift
//  medzTracker
//
//  Created by Alex Kaish on 3/4/22.
//

//View Class

import SwiftUI



struct ContentView: View {
    
    @ObservedObject var viewModel : MedicineTracker //ViewModel will be passed in
    @State var isOnAddingScreen = false
    @State var fromPushNotificationLocal = false
    
    
    // MARK: Actual View
    var body: some View {
        
        NavigationView {
            
            ZStack {
                List {
                    ForEach(viewModel.meds) {
                        med in
                        NavigationLink {
                            DetailsView(viewModel: viewModel,medication: med)
                        } label: {
                            MedicationRow(medication: med)
                        }
                    }.onDelete(perform:
                                {indexSet in
                        viewModel.removeMedicationsByIndexSet(indexSet: indexSet)})
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Image(systemName: "pills")
                            Text("MedsTracker")
                        }.font(.title).onTapGesture {
                            //MARK: Secret Button
                            print("tapped On Secret Button")
                            for medication in viewModel.meds {
                                viewModel.removeMedication(medication.id)
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddMedicineView(viewModel: viewModel, isOnAddingScreen: $isOnAddingScreen), isActive: $isOnAddingScreen) {
                            Image(systemName: "plus.circle")
                        }.font(.title2)
                        
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.insertDummyData()
                        } label: {
                            Image(systemName: "plus.square")
                        }.font(.title2)
                    }
                })
                //MARK: Invisible Link to handle Notifications
                if fromPushNotificationLocal {
                    NavigationLink(isActive: $fromPushNotificationLocal, destination: {
                        LogDosageView(viewModel: viewModel, medication: viewModel.getMedicationByUUID(NotificationHandler.shared.medicationIDToLog!)!, timeTaken: Date(), fromNotification: true, isOnLogView: $fromPushNotificationLocal )
                        
                    }, label: {Text("You'll never see this")}
                                   
                    ).hidden()
                }
            }.onReceive(NotificationHandler.shared.$cameFromNotification, perform: {(fromPush) in
                if fromPush {fromPushNotificationLocal = true
                    print("receieved message, logging : \(NotificationHandler.shared.medicationIDToLog?.uuidString ?? "nil")")
                }
            })
        }.navigationViewStyle(StackNavigationViewStyle()) //need this so it displays correct on iPad
        
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
//    init(medicine inputMed : Medication) {
//        medName = inputMed.name
//        medDosage = inputMed.readableDosage
//        timeDelta = inputMed.getLatestDosage()?.timeSinceDosageString
//        timeOfLastDosage = inputMed.getLatestDosage()?.timeString
//        //TODO: Only show this if its today
//    }
    @StateObject var medication : Medication

    var body : some View {
        //init some helper vars
        let medName = medication.name
        let medDosage = medication.readableDosage
        let nextDosageTimeString = medication.getNextDosageTime()?.timeOnlyFormattedString
        let timeDelta = medication.timeUntilNextDosageString
        @State var clockColor :Color = medication.overdue ? .red : .blue

        
        
        return VStack{
            HStack {
                Text(medName)
                    .font(.title3)
                Spacer()
//                Label(timeDelta ?? "N/A", systemImage: "timer")
                Label {
                    Text(timeDelta ?? "N/A")
                } icon: {
                    Image(systemName: "timer").foregroundColor(clockColor)
                }
                    
            }
            if medDosage != nil || nextDosageTimeString != nil{
                HStack{
                    if let medDosage = medDosage {
                        Text(medDosage)
                            .padding(.leading)
                    }
                    Spacer()
                    if let timeOfLastDosage = nextDosageTimeString {
                        Text("(\(timeOfLastDosage))")
                    }
                }.font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let tracker = MedicineTracker()
        tracker.insertDummyData()
        return ContentView(viewModel: tracker)
    }
}

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
    //Used to control view programticcaly
    @State var isOnAddingScreen = false
    @State var fromPushNotificationLocal = false
    @State var isShowingExtraButton = false ///for Quickly adding info
    
    
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
                            isShowingExtraButton.toggle()
                        }.onLongPressGesture {
                            print("held on scret button")
                            for medication in viewModel.meds {
                                viewModel.removeMedication(medication.id)
                            }
                            viewModel.saveData()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddMedicineView(viewModel: viewModel, isOnAddingScreen: $isOnAddingScreen), isActive: $isOnAddingScreen) {
                            Image(systemName: "plus.circle")
                        }.font(.title2)
                        
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isShowingExtraButton {
                        Button {
                            viewModel.insertDemoData()
                        } label: {
                            Image(systemName: "plus.square")
                        }.font(.title2)
                        }
                        else {
                            EmptyView()
                        }
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

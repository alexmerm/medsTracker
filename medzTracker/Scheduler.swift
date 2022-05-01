//
//  Scheduler.swift
//  medzTracker
//
//  Created by Alex Kaish on 4/30/22.
//

import Foundation
import SwiftUI
import UserNotifications

struct Scheduler {
    
    ///medID : [NotificationId]
    var notificationIDs : [UUID: [UUID]] = [:]
    
    mutating func storeNotification(medicationID: UUID, notificationID: UUID) {
        //If not there, create the arr
        if notificationIDs[medicationID] == nil {
            notificationIDs[medicationID] = [notificationID]
        } else {
            notificationIDs[medicationID]?.append(notificationID)
        }
    }
    
    func getNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.badge,.alert,.criticalAlert]) { success,error in
            if success {
                print("We got Permissions")
            } else if let error = error {
                print(error.localizedDescription)
                //TODO: Handle errors
            }
        }
    }
    mutating func scheduleNotification(medication: Medication) -> UUID? {
        precondition(medication.schedule.isScheduled(), "Medication have scheduler of scheudlign type")
        precondition(medication.reminders, "Must have reminders enabled")
        let content = generateNotification(medication: medication)
        guard let trigger = generateTrigger(medication: medication) else {
            return nil
        }
        let uuid = UUID() //Notification UUID
        let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        //Append to notificationIDS
        storeNotification(medicationID: medication.id, notificationID: uuid)
        return uuid
    }
    
    func generateNotification(medication : Medication) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "\(medication.name)"
        content.subtitle = "It's time to take your \(medication.name)!"
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive
        content.targetContentIdentifier = medication.id.uuidString
        content.threadIdentifier = medication.id.uuidString
        return content
    }
    //only accept medication where Medication.schedule is .isScheduled
    func generateTrigger(medication: Medication) -> UNNotificationTrigger? {
        //only run this on notifications with scheduled
        precondition(medication.schedule.isScheduled())
        //for intervals
        
        if case Medication.Schedule.intervalSchedule(interval: let interval) = medication.schedule {
            //if logged in last  min or never logged at all, schedi;e as interval, otherwise scjedi;e as date
            if medication.getLatestDosage() == nil || Date.now - 60 < medication.getLatestDosage()!.time {
                return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
            }
            else {
                //logged over an hr ago , Generate Inteval as Calendar
                if let triggerTime = medication.getNextDosageTime() {
                    return UNCalendarNotificationTrigger(dateMatching: triggerTime.asDateComponents, repeats: false)
                } else {
                    return nil
                }
            }
        } else if case Medication.Schedule.specificTime(hour: let hour, minute: let minute) = medication.schedule {
            return UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute), repeats: true)
        }
        //WIll never b
        return nil
    }
    
    
}

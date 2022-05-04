//
//  NotificationHandler.swift
//  medzTracker
//
//  Created by Alex Kaish on 5/3/22.
//

import Foundation
import UserNotifications

class NotificationHandler : NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    //When CLICKED from backgrouns
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:
                                UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //response.notification.request.content.threadIdentifier //use this to get to screen
        completionHandler()
    }
    
    // The method will be called on the delegate only if the application is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification Should go out for : \(notification.request.content.title)")
        completionHandler([.sound,.banner])
    }

    
}


extension NotificationHandler  {
    func requestPermission(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound,.alert,.badge]) { success, error in
            if success {
                //UNUserNotificationCenter.current().delegate = self.notificationDelegate
                print("We got Permissions")
            } else if let error = error {
                print(error.localizedDescription)
                //TODO: Handle errors
            }
        }
        
        center.delegate = self
    }
}

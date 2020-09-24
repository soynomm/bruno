import Foundation
import SwiftUI

class NotificationProvider
{
    public func remove(id: String)
    {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    public func create(id: String, date: Date, contents: String, block: @escaping () -> Void)
    {
        self.remove(id: id)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                let content = UNMutableNotificationContent()
                content.title = "Woof-woof"
                content.body = contents
                content.sound = UNNotificationSound.default
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)
            } else {
                block()
            }
        }
    }
}

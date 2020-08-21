import SwiftUI
import UserNotifications

struct TaskItemInfoView: View {
    @EnvironmentObject var data: DataStore
    @Environment(\.colorScheme) var colorScheme
    @Binding var task: TaskModel
    @State var selectedDate = Date()...
    @State var selectedTab: String = "info"

    func setTaskDateReminder() {
        self.task.dateReminderSet = true
    }
    
    func clearTaskDateReminder() {
        self.task.dateReminderSet = false
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.task.id])
    }
    
    func attemptSetTaskDateReminder(taskId: String, taskName: String, taskReminderDate: Date) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                let content = UNMutableNotificationContent()
                content.title = "Woof-woof"
                content.body = taskName
                content.sound = UNNotificationSound.default
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute], from: taskReminderDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)
                
                DispatchQueue.main.async {
                    self.setTaskDateReminder()
                }
            } else {
                DispatchQueue.main.async {
                    self.clearTaskDateReminder()
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Form {
                    Section(header: Text("Reminder")) {
                        if task.completed {
                            Text("You can't set a reminder for a completed task.")
                            .font(.footnote)
                        } else {
                            if self.task.dateReminderSet {
                                DatePicker("Reminder is set for", selection: $task.dateReminder)
                                Button(action: { self.clearTaskDateReminder() }, label: { Text("Clear reminder")})
                            } else {
                                DatePicker("Schedule a reminder", selection: $task.dateReminder)
                                Button(action: { self.attemptSetTaskDateReminder(taskId: self.task.id, taskName: self.task.name, taskReminderDate: self.task.dateReminder) }, label: { Text("Set reminder")})
                            }
                        }
                    }
                
                    Section(header: Text("Subtasks")) {
                        SubTasksView(parentId: self.task.id, parentCompleted: task.completed).environmentObject(DataStore())
                    }
                    
                    Section(header: Text("Notes")) {
                        if task.completed {
                            if task.notes != "" {
                                Text(task.notes)
                                .onTapGesture {
                                    UIPasteboard.general.string = self.task.notes
                                }
                            } else {
                                Text("You haven't added notes to this task and you can't add any for a completed task.")
                                .font(.footnote)
                            }
                        } else {
                            TextField("Your notes go here", text: $task.notes)
                        }
                    }
                }
                
            }
            .navigationBarTitle("Edit Task", displayMode: .inline)
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
                if self.task.dateReminder < Date() && self.task.dateReminderSet {
                    self.clearTaskDateReminder()
                }
                
                if self.task.dateReminder < Date() && !self.task.dateReminderSet {
                    self.task.dateReminder = Date()
                }
            }
            .onDisappear {
                if self.task.dateReminder < Date() && self.task.dateReminderSet {
                    self.clearTaskDateReminder()
                }
                
                if self.task.dateReminder < Date() && !self.task.dateReminderSet {
                    self.task.dateReminder = Date()
                }
            }
        }
    }
}

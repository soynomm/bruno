import SwiftUI
import UserNotifications

struct TaskItemInfoView: View {
    @ObservedObject var task: TaskObservable
    var subTasks: [SubTask]

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
            Form {
                Section(header: Text("Reminder").padding(.top, 15)) {
                    if task.completed {
                        Text("You can't set a reminder for a completed task.")
                        .font(.footnote)
                    } else {
                        if self.task.dateReminderSet {
                            DatePicker("Scheduled for", selection: $task.dateReminder)
                                .datePickerStyle(CompactDatePickerStyle())
                            Button(action: { self.clearTaskDateReminder() }, label: { Text("Clear reminder")})
                        } else {
                            DatePicker("Schedule for", selection: $task.dateReminder)
                                .datePickerStyle(CompactDatePickerStyle())
                            Button(action: { self.attemptSetTaskDateReminder(taskId: self.task.id, taskName: self.task.name, taskReminderDate: self.task.dateReminder) }, label: { Text("Set reminder")})
                        }
                    }
                }
            
                Section(header: Text("Subtasks")) {
                    SubTasksView(parentId: self.task.id, subTasks: self.subTasks)
                }
                
                Section(header: Text("Notes")) {
                    ZStack {
                        TextEditor(text: $task.notes)
                        Text(task.notes)
                            .padding(.bottom, 10)
                            .opacity(0)
                    }
                    .offset(x: -5)
                }
            }
            .navigationBarTitle(self.task.name, displayMode: .inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
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

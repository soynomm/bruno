import SwiftUI
import UserNotifications

struct TaskItemInfoView: View {
    @ObservedObject var db: DatabaseObservable
    @ObservedObject var task: TaskObservable
    var subTasks: [SubTask]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder").padding(.top, 15)) {
                    HStack {
                        DatePicker("", selection: $task.dateReminder).labelsHidden()
                            .frame(alignment: .trailing)
                        Rectangle().fill(Color.clear).frame(width:40)
                        Toggle("", isOn: $task.dateReminderSet).labelsHidden()
                    }
                }

                Section(header: Text("Subtasks")) {
                    SubTasksView(parentId: self.task.id, db: self.db, subTasks: self.subTasks)
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
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

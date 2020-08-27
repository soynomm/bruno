import SwiftUI
import UserNotifications

struct TaskItemInfoView: View {
    @ObservedObject var db: DatabaseObservable
    @ObservedObject var task: TaskObservable
    var subTasks: [SubTask]
    @State var showDatePicker: Bool = false
    
    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date & Time").padding(.top, 15)) {
                    HStack {
                        Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.primary)
                        .font(Font.title.weight(.light))
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            showDatePicker.toggle()
                        }
                        
                        Text("\(task.dueDate, formatter: dateFormatter())")
                        .padding(.leading, 3)
                        .onTapGesture {
                            showDatePicker.toggle()
                        }
                    }
                    if showDatePicker {
                        DatePicker("", selection: $task.dueDate)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                    HStack {
                        Text("Due date")
                        Spacer()
                        Toggle("", isOn: $task.dueDateSet).labelsHidden()
                    }
                    HStack {
                        Text("Reminder")
                        Spacer()
                        Toggle("", isOn: $task.dueDateReminderSet).labelsHidden()
                    }
                }

                Section(header: Text("Subtasks")) {
                    SubTasksView(parentId: self.task.id, db: self.db, subTasks: self.subTasks)
                }
                
                Section(header: Text("Notes")) {
                    ZStack(alignment: .leading) {
                        if task.notes.isEmpty {
                            Text("Notes ..")
                            .foregroundColor(Color.secondary)
                        }
                        TextEditor(text: $task.notes)
                            .offset(x: -5)
                        Text(task.notes)
                            .padding(.bottom, 10)
                            .opacity(0)
                    }
                }
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

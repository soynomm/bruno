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
                Section(header: Text("Reminder").padding(.top, 15)) {
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
                        
                        Text("\(task.dateReminder, formatter: dateFormatter())")
                        .padding(.leading, 3)
                        .onTapGesture {
                            showDatePicker.toggle()
                        }

                        //Rectangle().fill(Color.clear).frame(width:40)
                        Spacer()
                        Toggle("", isOn: $task.dateReminderSet).labelsHidden()
                    }
                    if showDatePicker {
                        DatePicker("", selection: $task.dateReminder)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
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

import SwiftUI
import UserNotifications

struct TaskItemInfoView: View {
    @ObservedObject var task: TaskObservable
    @Environment(\.colorScheme) var colorScheme
    @State var showDatePicker: Bool = false
    @State var taskNotes: String = ""

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
                        .foregroundColor(colorScheme == .dark ? AppConfiguration().primaryColorDark : AppConfiguration().primaryColor)
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
                    SubTasksView(parentId: self.task.id)
                }
                
                Section(header: Text("Notes")) {
                    ZStack(alignment: .leading) {
                        if taskNotes.isEmpty {
                            Text("Notes ..")
                            .foregroundColor(Color.secondary)
                        }
                        TextEditor(text: $taskNotes)
                        .offset(x: -5)
                        .onChange(of: taskNotes) { newValue in
                            self.task.notes = newValue
                        }
                        
                        Text(taskNotes)
                        .padding(.bottom, 10)
                        .opacity(0)
                    }
                }
            }
            .navigationBarTitle(self.task.name, displayMode: .inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if self.taskNotes.isEmpty {
                    self.taskNotes = self.task.notes
                }
            }
        }
    }
}

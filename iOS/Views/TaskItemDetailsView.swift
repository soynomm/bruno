import SwiftUI
import UserNotifications

struct TaskItemDetailsSectionTitle: View {
    var title: String = ""
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(self.title)
            .foregroundColor(Color.gray)
            .font(.caption)
            .fontWeight(Font.Weight.semibold)
            .textCase(.uppercase)
            .padding(.top, 25)
            .padding(.bottom, 5)
    }
}

struct TaskItemDetailsView: View {
    @ObservedObject var task: TaskObservable
    @Environment(\.colorScheme) var colorScheme
    @State var showDatePicker: Bool = false
    @State var taskName: String = ""
    @State var taskNotes: String = ""
    var onComplete: (() -> Void)
    let throttler = Throttler(minimumDelay: 0.25)

    func dateFormatter() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
    
    func updateTaskName(newValue: String)
    {
        throttler.throttle {
            self.task.name = newValue
        }
    }
    
    func updateTaskNotes(newValue: String)
    {
        throttler.throttle {
            self.task.notes = newValue
        }
    }

    func completeTask()
    {
        if task.completed {
            task.completed = false
        } else {
            task.completed = true
        }
        
        self.onComplete()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                HStack(alignment: .top) {
                    // Task checkbox
                    if task.completed {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.light))
                            .frame(width: 26, height: 26, alignment: .topLeading)
                            .onTapGesture(perform: self.completeTask)
                            .padding(.top, 3)
                            .padding(.trailing, 5)
                    } else {
                        Image(systemName: "circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.light))
                            .frame(width: 26, height: 26, alignment: .topLeading)
                            .onTapGesture(perform: self.completeTask)
                            .padding(.top, 3)
                            .padding(.trailing, 5)
                    }
                    
                    // Task name
                    ZStack(alignment: .leading) {
                        TextEdit(text: $taskName, font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold))
                            .onChange(of: taskName, perform: self.updateTaskName)
                            .offset(x: -5, y: -5)
                        
                        if taskName.isEmpty {
                            Text("Task name ...")
                                .font(.title2)
                                .fontWeight(Font.Weight.semibold)
                                .opacity(0.5)
                                .offset(y: -5)
                                .padding(.all, 0)
                        }
                    }
                }
                
                Rectangle()
                    .fill(Color.gray)
                    .opacity(0.25)
                    .cornerRadius(5)
                    .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
                
                TaskItemDetailsSectionTitle("Reminder")
            
                // Reminder
                HStack {
                    DatePicker("", selection: $task.dueDate)
                        .labelsHidden()
                    Spacer()
                    Toggle("", isOn: $task.dueDateReminderSet).labelsHidden()
                }
                
                if task.dueDateReminderSet {
                    if showDatePicker {
                        HStack(alignment: .center) {
                            Spacer()
                            DatePicker("", selection: $task.dueDate)
                                .labelsHidden()
                                .datePickerStyle(WheelDatePickerStyle())
                            Spacer()
                            
                            .animation(Animation.default)
                        }
                    }
                }

                // Tasks
                TaskItemDetailsSectionTitle("Tasks")
                SubTasksView(parentId: self.task.id)
                    .offset(y: -5)
                
                // Notes
                TaskItemDetailsSectionTitle("Notes")
                ZStack(alignment: .leading) {
                    if taskNotes == "" {
                        Text("Notes ...")
                            .font(Font.system(size: 17))
                            .foregroundColor(Color.secondary)
                            .offset(y: -5)
                    }
                    TextEdit(text: $taskNotes, font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular))
                        .offset(x: -5, y: -5)
                        .onChange(of: taskNotes, perform: self.updateTaskNotes)
                }
            }
            
            .padding(25)
            .onAppear {
                if self.taskName == "" {
                    self.taskName = self.task.name
                }
                
                if self.taskNotes == "" {
                    self.taskNotes = self.task.notes
                }
            }
        }
    }
}

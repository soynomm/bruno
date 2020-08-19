import SwiftUI

struct TaskItemView: View {
    
    @EnvironmentObject var data: DataStore
    @Binding var task: TaskModel
    @State var showInfoButton: Bool = false
    @State var showTaskInfo: Bool = false
    
    func completeTask() {
        if task.completed {
            task.completed = false
        } else {
            task.completed = true
            task.dateReminderSet = false
        }
    }
    
    func displayDateReminder() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: task.dateReminder)
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                if task.completed {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22, alignment: .topLeading)
                        .onTapGesture {
                            self.completeTask()
                        }
                } else {
                    Image(systemName: "circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22, alignment: .topLeading)
                        .onTapGesture {
                            self.completeTask()
                        }
                }
                
                TextField("Task name", text: $task.name)

                if task.dateReminderSet && !task.completed {
                    if task.dateReminder < Date() {
                        Image(systemName: "bell")
                            .foregroundColor(Color.red)
                            .padding(.top, 4)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    } else {
                        Image(systemName: "bell")
                            .foregroundColor(Color.blue)
                            .padding(.top, 4)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    }
                }

                Image(systemName: "info.circle")
                    .padding(.top, 4)
                    .onTapGesture {
                        self.showTaskInfo = true
                    }

            }
        }
        .sheet(isPresented: $showTaskInfo, content: {
            TaskItemInfoView(task: self.$task).environmentObject(DataStore())
        })
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(task: .constant(TaskModel())).environmentObject(DataStore())
    }
}

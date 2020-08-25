import SwiftUI

struct TaskItemView: View {
    @ObservedObject var task: TaskObservable
    var subTasks: [SubTask]
    @State var taskName: String = ""
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
                
                if task.completed {
                    Text(task.name)
                    .strikethrough()
                } else {
                    TextField("Task name", text: $task.name)
                }
                
                Spacer()

                if task.dateReminderSet && !task.completed {
                    if task.dateReminder < Date() {
                        Image(systemName: "bell")
                            .foregroundColor(Color.red)
                            .padding(.top, 2)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    } else {
                        Image(systemName: "bell")
                            .foregroundColor(Color.blue)
                            .padding(.top, 2)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    }
                }

                Image(systemName: "info.circle")
                    .padding(.top, 2)
                    .onTapGesture {
                        self.showTaskInfo = true
                    }

            }
        }
        .sheet(isPresented: $showTaskInfo, content: {
            TaskItemInfoView(task: self.task, subTasks: self.subTasks)
        })
        .onAppear {
            self.taskName = self.task.name
        }
    }
}

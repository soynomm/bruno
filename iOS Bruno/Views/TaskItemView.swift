import SwiftUI

struct TaskItemView: View {
    @ObservedObject var task: TaskObservable
    @ObservedObject var db: DatabaseObservable
    var subTasks: [SubTask]
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
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.red)
                            .frame(width: 19, height: 19)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    } else {
                        Image(systemName: "bell")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.blue)
                            .frame(width: 19, height: 19)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    }
                }

                Image(systemName: "info.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 19, height: 19)
                    .onTapGesture {
                        self.showTaskInfo = true
                    }

            }
        }
        .sheet(isPresented: $showTaskInfo, content: {
            TaskItemInfoView(db: self.db, task: self.task, subTasks: self.subTasks)
        })
    }
}

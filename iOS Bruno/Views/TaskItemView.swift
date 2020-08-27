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
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                if task.completed {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(Font.title.weight(.light))
                        .frame(width: 22, height: 22, alignment: .topLeading)
                        .onTapGesture {
                            self.completeTask()
                        }
                } else {
                    Image(systemName: "circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(Font.title.weight(.light))
                        .frame(width: 22, height: 22, alignment: .topLeading)
                        .onTapGesture {
                            self.completeTask()
                        }
                }
                
                if task.completed {
                    Text(task.name)
                    .strikethrough()
                    .padding(.top, 1)
                } else {
                    TextField("Task name", text: $task.name)
                }
                
                Spacer()
                
                if task.dueDateSet && !task.completed {
                    if task.dueDate < Date() {
                        Image(systemName: "clock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.red)
                            .font(Font.title.weight(.light))
                            .frame(width: 17, height: 17)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    } else {
                        Image(systemName: "clock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.blue)
                            .font(Font.title.weight(.light))
                            .frame(width: 17, height: 17)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    }
                }

                if task.dueDateReminderSet && !task.completed {
                    if task.dueDate < Date() {
                        Image(systemName: "bell")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.red)
                            .font(Font.title.weight(.light))
                            .frame(width: 17, height: 17)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    } else {
                        Image(systemName: "bell")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.blue)
                            .font(Font.title.weight(.light))
                            .frame(width: 17, height: 17)
                            .onTapGesture {
                                self.showTaskInfo = true
                        }
                    }
                }

                Image(systemName: "info.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.secondary)
                    .font(Font.title.weight(.light))
                    .frame(width: 17, height: 17)
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

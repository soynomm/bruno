import SwiftUI

struct TaskItemView: View {
    @ObservedObject var task: TaskObservable
    @Binding var tasks: [Task]
    @State var showInfoButton: Bool = false
    @State var showTaskInfo: Bool = false
    var throttler = Throttler(minimumDelay: 0.25)
    
    func completeTask() {
        let taskIndex = tasks.firstIndex { $0.id == task.id }
        
        if task.completed {
            task.completed = false
            
            throttler.throttle {
                self.tasks[taskIndex!].completed = false
                self.tasks[taskIndex!].dateCompleted = Date()
            }
        } else {
            task.completed = true
            
            throttler.throttle {
                self.tasks[taskIndex!].completed = true
                self.tasks[taskIndex!].dateCompleted = Date()
            }
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
                    .onChange(of: task.name) { newValue in
                        throttler.throttle {
                            let index = self.tasks.firstIndex { $0.id == task.id }
                            self.tasks[index!].name = newValue
                        }
                    }
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

                Image(systemName: "i.circle")
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
            TaskItemInfoView(task: self.task)
        })
    }
}

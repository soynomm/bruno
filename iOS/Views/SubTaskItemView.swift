import SwiftUI

struct SubTaskItemView: View {
    @ObservedObject var task: SubTaskObservable
    @Binding var tasks: [SubTask]
    var throttler = Throttler(minimumDelay: 0.25)
    
    func completeTask() {
        let taskIndex = tasks.firstIndex { $0.id == task.id }
        
        if task.completed {
            task.completed = false
            
            throttler.throttle {
                self.tasks[taskIndex!].completed = false
            }
        } else {
            task.completed = true
            
            throttler.throttle {
                self.tasks[taskIndex!].completed = true
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
                } else {
                    TextField("Task name", text: $task.name)
                        .onChange(of: task.name) { newValue in
                            throttler.throttle {
                                let taskIndex = self.tasks.firstIndex { $0.id == task.id }
                                self.tasks[taskIndex!].name = newValue
                            }
                        }
                }
            }
        }
    }
}

import SwiftUI

struct SubTaskItemView: View {
    @ObservedObject var task: SubTaskObservable
    
    func completeTask() {
        if task.completed {
            task.completed = false
        } else {
            task.completed = true
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
                
                TextField("Task name", text: $task.name)
            }
        }
    }
}

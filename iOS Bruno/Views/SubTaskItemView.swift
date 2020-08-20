import SwiftUI

struct SubTaskItemView: View {
    
    @EnvironmentObject var data: DataStore
    @Binding var task: SubTaskModel
    var parentCompleted: Bool
    
    func completeTask() {
        if !parentCompleted {
            if task.completed {
                task.completed = false
            } else {
                task.completed = true
            }
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
                    if !parentCompleted {
                        TextField("Task name", text: $task.name)
                    }
                }

            }
        }
    }
}

struct SubTaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        SubTaskItemView(task: .constant(SubTaskModel()), parentCompleted: false).environmentObject(DataStore())
    }
}

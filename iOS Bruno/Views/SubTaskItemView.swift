import SwiftUI

struct SubTaskItemView: View {
    
    @EnvironmentObject var data: DataStore
    @Binding var task: SubTaskModel
    
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

struct SubTaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        SubTaskItemView(task: .constant(SubTaskModel())).environmentObject(DataStore())
    }
}

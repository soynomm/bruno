import SwiftUI

struct SubTasksView: View {
    var parentId: String
    var subTasks: [SubTask]

    func getSubTaskListItems() -> [SubTask] {
        let taskList = self.subTasks.sorted(by: { $0.dateCreated < $1.dateCreated }).filter {
            $0.parentId == self.parentId
        }
        
        return taskList
    }
    
    func addSubTask(){
        Kettle().addSubTask(SubTask(parentId: self.parentId))
    }
    
    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let task = self.subTasks[index]
            Kettle().deleteSubTask(task)
        }
    }
    
    var body: some View {
        List {
            if getSubTaskListItems().count > 0 {
                ForEach(getSubTaskListItems()) { task in
                    SubTaskItemView(task: SubTaskObservable(task: task))
                }
                .onDelete(perform: self.delete)
            } else {
                Text("You haven't created any subtasks.")
                .font(.footnote)
            }
            
            Button(action: self.addSubTask, label: { Text("Add task").foregroundColor(Color.blue) })
        }
    }
}

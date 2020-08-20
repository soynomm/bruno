import SwiftUI

struct SubTasksView: View {
    @EnvironmentObject var data: DataStore
    var parentId: String

    func getSubTaskListItems() -> [SubTaskModel] {
        let taskList = data.subTasks.sorted(by: { $0.dateCreated < $1.dateCreated }).filter {
            $0.parentId == self.parentId
        }
        
        return taskList
    }
    
    func addSubTask(){
        data.subTaskDB.create(SubTaskModel(parentId: self.parentId))
    }
    
    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let task = data.subTasks[index]
            data.subTaskDB.delete(task)
        }
    }
    
    var body: some View {
        List {
            ForEach(getSubTaskListItems()) { task in
                SubTaskItemView(task: task.realmBinding())
            }
            .onDelete(perform: self.delete)
            
            Button(action: self.addSubTask, label: { Text("Add task").foregroundColor(Color.blue) })
        }
    }
}

struct SubTasksView_Previews: PreviewProvider {
    static var previews: some View {
        SubTasksView(parentId: "").environmentObject(DataStore())
    }
}

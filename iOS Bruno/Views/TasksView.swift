import SwiftUI

struct TasksView: View {
    @EnvironmentObject var data: DataStore
    var listId: String
    @State var hideCompletedItems: Bool = false
    
    func getTaskListItems(completed: Bool) -> [TaskModel] {
        let taskList = data.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.listId
        }
        
        return taskList.filter {
            $0.completed == completed
        }
    }
    
    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let task = data.tasks[index]
            data.taskDB.delete(task)
        }
    }
    
    func hasCompletedTasks() -> Bool {
        var hasCompletedTasks = false
        
        for t in data.tasks {
            if t.listId == self.listId && t.completed == true {
                hasCompletedTasks = true
            }
        }
        
        return hasCompletedTasks
    }
    
    func unCompletedTasksSection() -> some View {
        return Section {
            ForEach(getTaskListItems(completed: false)) { task in
                TaskItemView(task: task.realmBinding())
            }
            .onDelete(perform: self.delete)
        }
    }
    
    func completedTasksSection() -> some View {
        return Section(header: HStack {
            Text("Completed")
            Spacer()
            Button(action: {
                if self.hideCompletedItems {
                    self.hideCompletedItems = false
                } else {
                    self.hideCompletedItems = true
                }
            }, label: {
                if self.hideCompletedItems {
                    Text("Show completed tasks")
                } else {
                    Text("Hide completed tasks")
                }
            })}) {
                if !self.hideCompletedItems {
                    ForEach(getTaskListItems(completed: true)) { task in
                        TaskItemView(task: task.realmBinding())
                    }
                    .onDelete(perform: self.delete)
                }
            }
    }
    
    var body: some View {
        Group {
            List {
                unCompletedTasksSection()
                if self.hasCompletedTasks() {
                    completedTasksSection()
                }
            }
            .listStyle(GroupedListStyle())
            
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(listId: "").environmentObject(DataStore())
    }
}

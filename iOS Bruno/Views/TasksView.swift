import SwiftUI

struct TasksView: View {
    @ObservedObject var observer: KettleObserver
    @ObservedObject var hideCompletedTasks: ConfigurationObservable
    var listId: String

    func getTaskListItems(completed: Bool) -> [Task] {
        let taskList = observer.db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.listId
        }
        
        return taskList.filter {
            $0.completed == completed
        }
    }
    
    func deleteUncompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = observer.db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.listId && $0.completed == false
        }
        
        for index in indexes {
            let task = taskList[index]
            Kettle().deleteTask(task)
        }
    }
    
    func deleteCompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = observer.db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.listId && $0.completed == true
        }
        
        for index in indexes {
            let task = taskList[index]
            Kettle().deleteTask(task)
        }
    }
    
    func hasCompletedTasks() -> Bool {
        var hasCompletedTasks = false
        
        for t in observer.db.tasks {
            if t.listId == self.listId && t.completed == true {
                hasCompletedTasks = true
            }
        }
        
        return hasCompletedTasks
    }
    
    func unCompletedTasksSection() -> some View {
        return Section {
            ForEach(getTaskListItems(completed: false), id: \.id) { task in
                TaskItemView(task: TaskObservable(task: task), subTasks: observer.db.subTasks)
            }
            .onDelete(perform: self.deleteUncompleted)
        }
    }
    
    func completedTasksSection() -> some View {
        return Section(header: HStack {
            Text("Completed")
            Spacer()
            Button(action: {
                if self.hideCompletedTasks.value == "yes" {
                    self.hideCompletedTasks.value = "no"
                } else {
                    self.hideCompletedTasks.value = "yes"
                }
            }, label: {
                if self.hideCompletedTasks.value == "yes" {
                    Text("Show completed tasks")
                } else {
                    Text("Hide completed tasks")
                }
            })}) {
                if self.hideCompletedTasks.value == "no" {
                    ForEach(getTaskListItems(completed: true), id: \.id) { task in
                        TaskItemView(task: TaskObservable(task: task), subTasks: observer.db.subTasks)
                    }
                    .onDelete(perform: self.deleteCompleted)
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

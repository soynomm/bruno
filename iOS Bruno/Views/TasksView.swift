import SwiftUI

struct TasksView: View {
    @ObservedObject var db: DatabaseObservable
    @State var hideCompletedTasks: Bool = false
    @State var counter: Int = 0
    var listId: String

    func getTaskListItems(completed: Bool) -> [Task] {
        let taskList = db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.listId
        }
        
        return taskList.filter {
            $0.completed == completed
        }
    }
    
    func deleteUncompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.listId && $0.completed == false
        }
        
        for index in indexes {
            let task = taskList[index]
            db.tasks = db.tasks.filter { $0.id != task.id }
        }
    }
    
    func deleteCompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.listId && $0.completed == true
        }
        
        for index in indexes {
            let task = taskList[index]
            db.tasks = db.tasks.filter { $0.id != task.id }
        }
    }
    
    func hasCompletedTasks() -> Bool {
        var hasCompletedTasks = false
        
        for t in db.tasks {
            if t.listId == self.listId && t.completed == true {
                hasCompletedTasks = true
            }
        }
        
        return hasCompletedTasks
    }
    
    func unCompletedTasksSection() -> some View {
        return Section {
            ForEach(getTaskListItems(completed: false), id: \.id) { task in
                TaskItemView(task: TaskObservable(task: task, db: db), db: db, subTasks: db.subTasks)
            }
            .onDelete(perform: self.deleteUncompleted)
        }
    }
    
    func completedTasksSection() -> some View {
        return Section(header: HStack {
            Text("Completed")
            Spacer()
            Button(action: {
                if self.hideCompletedTasks {
                    self.hideCompletedTasks = false
                } else {
                    self.hideCompletedTasks = true
                }
            }, label: {
                if self.hideCompletedTasks {
                    Text("Show completed tasks")
                } else {
                    Text("Hide completed tasks")
                }
            })}) {
                if !self.hideCompletedTasks {
                    ForEach(getTaskListItems(completed: true), id: \.id) { task in
                        TaskItemView(task: TaskObservable(task: task, db: db), db: db, subTasks: db.subTasks)
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
            .id(self.counter)
            .listStyle(GroupedListStyle())
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            self.counter += 1
        }
    }
}

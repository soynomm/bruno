import SwiftUI

struct SubTasksView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var tasks: [SubTask] = []
    var parentId: String
    var throttler = Throttler(minimumDelay: 0.25)

    func addSubTask(){
        self.tasks.append(SubTask(parentId: self.parentId))
    }
    
    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let task = self.tasks[index]
            let tasks = self.tasks.filter { $0.id != task.id }
            DataProvider().updateSubTasks(tasks)
            self.tasks = tasks
        }
    }
    
    var body: some View {
        List {
            if self.tasks.sorted(by: { $0.dateCreated < $1.dateCreated }).count > 0 {
                ForEach(self.tasks.sorted(by: { $0.dateCreated < $1.dateCreated })) { task in
                    SubTaskItemView(task: SubTaskObservable(task: task), tasks: self.$tasks)
                }
                .onDelete(perform: self.delete)
            }
            
            Button(action: self.addSubTask, label: { Text("Add task").foregroundColor(colorScheme == .dark ? AppConfiguration().primaryColorDark : AppConfiguration().primaryColor) })
        }
        .onAppear {
            throttler.throttle {
                if self.tasks.isEmpty {
                    self.tasks = DataProvider().getSubTasks(self.parentId)
                }
            }
        }
    }
}

import SwiftUI

struct SubTasksView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var tasks: [SubTask] = []
    var parentId: String
    var throttler = Throttler(minimumDelay: 0.25)

    func add()
    {
        // Find the topmost task
        let lastTask = self.tasks.filter({ $0.parentId == self.parentId }).last
        
        // If the last task exists and is not empty, let's create a new task
        if lastTask != nil && !lastTask!.name.isEmpty {
            self.tasks.append(SubTask(parentId: self.parentId))
        }
        
        // If the last task does not exist, let's create a new task
        if lastTask == nil {
            self.tasks.append(SubTask(parentId: self.parentId))
        }
    }
    
    func delete(_ taskId: String)
    {
        let updatedTasks = self.tasks.filter { $0.id != taskId }
        self.tasks = updatedTasks
        DataProvider().updateSubTasks(updatedTasks)
    }
    
    var body: some View {
        if self.tasks.sorted(by: { $0.dateCreated < $1.dateCreated }).filter({ $0.parentId == self.parentId }).count > 0 {
            ForEach(self.tasks.sorted(by: { $0.dateCreated < $1.dateCreated }).filter({ $0.parentId == self.parentId })) { task in
                SubTaskItemView(task: SubTaskObservable(task: task), tasks: self.$tasks, onDelete: self.delete)
            }
        }
            
        Button(action: self.add, label: { Text("Add task").foregroundColor(colorScheme == .dark ? AppConfiguration().primaryColorDark : AppConfiguration().primaryColor) })
            .padding(.top, 5)
            
        .onAppear {
            throttler.throttle {
                if self.tasks.isEmpty {
                    self.tasks = DataProvider().getSubTasks()
                }
            }
        }
    }
}

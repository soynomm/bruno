import SwiftUI

struct SubTasksView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var tasks: [SubTask] = []
    var parentId: String
    var throttler = Throttler(minimumDelay: 0.25)
    @State var dataHasLoaded = false

    func add()
    {
        self.tasks.append(SubTask(parentId: self.parentId))
    }
    
    func delete(_ taskId: String)
    {
        let updatedTasks = self.tasks.filter { $0.id != taskId }
        self.tasks = updatedTasks
        DataProvider().updateSubTasks(updatedTasks)
    }
    
    var body: some View {
        if self.dataHasLoaded {
            ForEach(self.tasks.sorted(by: { $0.dateCreated < $1.dateCreated }).filter({ $0.parentId == self.parentId })) { task in
                SubTaskItemView(task: SubTaskObservable(task: task), onDelete: self.delete)
            }
        } else {
            SubTaskItemPhantomView()
            SubTaskItemPhantomView()
            SubTaskItemPhantomView()
        }
            
        Button(action: self.add, label: {
            Text("Add task")
        })
            .padding(.top, 5)
            
        .onAppear {
            throttler.throttle {
                if self.tasks.isEmpty {
                    self.tasks = DataProvider().getSubTasks()
                    self.dataHasLoaded = true
                }
            }
        }
    }
}

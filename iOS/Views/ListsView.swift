import SwiftUI

struct ListsView: View {
    @Binding var lists: [TaskList]
    @Binding var tasks: [Task]
    @Binding var currentListId: String
    @Binding var showSheet: Bool
    @State var isEditMode: EditMode = .inactive
    
    // Create a new list.
    func addItem()
    {
        // But only if the last list is not empty!
        let lastList = self.lists.last
        
        if lastList != nil && !lastList!.name.isEmpty {
            self.lists.append(TaskList())
            self.isEditMode = .active
        }
    }
    
    // Get the number of tasks within a list.
    func getListTaskCount(listId: String) -> Int
    {
        return self.tasks.filter({ $0.listId == listId && $0.completed == false }).count
    }

    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let list = self.lists[index]
            
            // delete tasks
            for task in self.tasks {
                if task.listId == list.id {
                    let tasks = self.tasks.filter { $0.id != task.id }
                    DataProvider().updateTasks(tasks)
                    self.tasks = tasks
                }
            }
            
            // if this list is also the active one, set currentListId to ""
            if self.currentListId == list.id {
                self.currentListId = ""
            }
            
            // delete list
            let lists = self.lists.filter { $0.id != list.id }
            DataProvider().updateLists(lists)
            self.lists = lists
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    HStack {
                        Button(action: {
                            self.currentListId = ""
                            self.showSheet = false
                        }, label: {
                            if currentListId == "" {
                                Text("Inbox")
                                .fontWeight(.bold)
                            } else {
                                Text("Inbox")
                            }
                        })
                        Spacer()
                        if self.getListTaskCount(listId: "") == 1 {
                            Text(String(self.getListTaskCount(listId: "")) + " task")
                            .font(.caption)
                        } else {
                            Text(String(self.getListTaskCount(listId: "")) + " tasks")
                            .font(.caption)
                        }
                    }
                    
                    ForEach(self.lists, id: \.id) { list in
                        ListItemView(list: TaskListObservable(list: list), lists: self.$lists, currentListId: self.$currentListId, editMode: self.isEditMode, taskCount: self.getListTaskCount(listId: list.id), showSheet: self.$showSheet)
                    }
                    .onDelete(perform: self.delete)
                }
            }
            
            .navigationBarTitle("Lists", displayMode: .inline)
            .navigationBarItems(leading: EditButton(), trailing: Button(action: addItem, label: {
                    Text("Add")
            }))
            .environment(\.editMode, self.$isEditMode)
        }
    }
}

import SwiftUI

struct ListsView: View {
    @ObservedObject var observer: KettleObserver
    @Binding var currentListId: String
    @Binding var showLists: Bool
    @State var isEditMode: EditMode = .inactive
    
    func addItem() {
        Kettle().addList(TaskList())
        self.isEditMode = .active
    }
    
    func getListTaskCount(listId: String) -> Int {
        var count = 0
        for task in observer.db.tasks {
            if task.listId == listId && task.completed == false {
                count += 1
            }
        }
        
        return count
    }

    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let list = observer.db.lists[index]
            
            // delete tasks
            for task in observer.db.tasks {
                if task.listId == list.id {
                    Kettle().deleteTask(task)
                }
            }
            
            // if this list is also the active one, set currentListId to ""
            if self.currentListId == list.id {
                self.currentListId = ""
            }
            
            // delete list
            Kettle().deleteList(list)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    HStack {
                        Button(action: {
                            self.currentListId = ""
                            self.showLists = false
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
                    
                    ForEach(observer.db.lists, id: \.id) { list in
                        ListItemView(list: TaskListObservable(list: list), currentListId: self.$currentListId, editMode: self.isEditMode, taskCount: self.getListTaskCount(listId: list.id), showLists: self.$showLists)
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

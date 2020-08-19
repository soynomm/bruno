import SwiftUI

struct ListsView: View {
    @EnvironmentObject var data: DataStore
    @Binding var currentListId: String
    @Binding var showLists: Bool
    @State var isEditMode: EditMode = .inactive
    
    func addItem() {
        data.listDB.create(TaskListModel())
        self.isEditMode = .active
    }
    
    func getListTaskCount(listId: String) -> Int {
        var count = 0
        for task in data.tasks {
            if task.listId == listId && task.completed == false {
                count += 1
            }
        }
        
        return count
    }

    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let list = data.lists[index]
            
            // delete tasks
            for task in data.tasks {
                if task.listId == list.id {
                    data.taskDB.delete(task)
                }
            }
            
            // if this list is also the active one, set currentListId to ""
            if self.currentListId == list.id {
                self.currentListId = ""
            }
            
            // delete list
            data.listDB.delete(list)
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
                    
                    ForEach(data.lists, id: \.id) { list in
                        ListItemView(list: list.realmBinding(), currentListId: self.$currentListId, editMode: self.isEditMode, taskCount: self.getListTaskCount(listId: list.id), showLists: self.$showLists).environmentObject(DataStore())
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


struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView(currentListId: .constant(""), showLists: .constant(true)).environmentObject(DataStore())
    }
}

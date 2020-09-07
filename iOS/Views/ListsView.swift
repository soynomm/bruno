import SwiftUI

struct ListsView: View {
    @ObservedObject var db: DatabaseObservable
    @Binding var currentListId: String
    @Binding var showSheet: Bool
    @State var isEditMode: EditMode = .inactive
    
    func addItem() {
        db.lists.append(TaskList())
        self.isEditMode = .active
    }
    
    func getListTaskCount(listId: String) -> Int {
        var count = 0
        for task in db.tasks {
            if task.listId == listId && task.completed == false {
                count += 1
            }
        }
        
        return count
    }

    func delete(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        
        for index in indexes {
            let list = db.lists[index]
            
            // delete tasks
            for task in db.tasks {
                if task.listId == list.id {
                    db.tasks = db.tasks.filter { $0.id != task.id }
                }
            }
            
            // if this list is also the active one, set currentListId to ""
            if self.currentListId == list.id {
                self.currentListId = ""
            }
            
            // delete list
            db.lists = db.lists.filter { $0.id != list.id }
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
                    
                    ForEach(db.lists, id: \.id) { list in
                        ListItemView(list: TaskListObservable(list: list, db: self.db), currentListId: self.$currentListId, editMode: self.isEditMode, taskCount: self.getListTaskCount(listId: list.id), showSheet: self.$showSheet)
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

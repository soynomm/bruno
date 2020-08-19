import SwiftUI

struct ListItemView: View {
    @EnvironmentObject var data: DataStore
    @Binding var list: TaskListModel
    @Binding var currentListId: String
    var editMode: EditMode
    var taskCount: Int
    @Binding var showLists: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                self.currentListId = self.list.id
                self.showLists = false
            }, label: {
                if self.editMode == .active {
                    TextField("List name", text: $list.name)
                } else {
                    if currentListId == list.id {
                        Text(list.name)
                            .fontWeight(.bold)
                    } else {
                        Text(list.name)
                    }
                }
            })
            Spacer()
            if taskCount == 1 {
                Text(String(taskCount) + " task")
                .font(.caption)
            } else {
                Text(String(taskCount) + " tasks")
                .font(.caption)
            }
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(list: .constant(TaskListModel()), currentListId: .constant(""), editMode: .inactive, taskCount: 10, showLists: .constant(true)).environmentObject(DataStore())
    }
}

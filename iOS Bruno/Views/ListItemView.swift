import SwiftUI

struct ListItemView: View {
    @ObservedObject var list: TaskListObservable
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

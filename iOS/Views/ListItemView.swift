import SwiftUI

struct ListItemView: View {
    @ObservedObject var list: TaskListObservable
    @Binding var lists: [TaskList]
    @Binding var currentListId: String
    var editMode: EditMode
    var taskCount: Int
    @Binding var showSheet: Bool
    var throttler = Throttler(minimumDelay: 0.25)
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                self.currentListId = self.list.id
                self.showSheet = false
            }, label: {
                if self.editMode == .active {
                    TextField("List name", text: $list.name)
                    .onChange(of: list.name) { newValue in
                        throttler.throttle {
                            let listIndex = lists.firstIndex { $0.id == list.id }
                            lists[listIndex!].name = newValue
                        }
                    }
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

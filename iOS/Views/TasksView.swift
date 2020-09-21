import SwiftUI

struct TasksView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var currentTab: String = "todo"
    @State var currentListId: String = ""
    @State var showSheetType: String = ""
    @State var counter: Int = 0
    @State var tasks: [Task] = []
    @State var lists: [TaskList] = []
    
    func getTaskListItems(completed: Bool) -> [Task] {
        var taskList: [Task] = []
        
        if completed {
            taskList = self.tasks.filter({ $0.listId == self.currentListId && $0.completed == completed }).sorted(by: { $0.dateCompleted! > $1.dateCompleted! })
        } else {
            taskList = self.tasks.filter({ $0.listId == self.currentListId && $0.completed == completed }).sorted(by: { $0.dateCreated > $1.dateCreated })
        }
        
        return taskList
    }
    
    func deleteUncompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = self.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.currentListId && $0.completed == false
        }
        
        for index in indexes {
            let task = taskList[index]
            let tasks = self.tasks.filter { $0.id != task.id }
            DataProvider().updateTasks(tasks)
            self.tasks = self.tasks.filter { $0.id != task.id }
        }
    }
    
    func deleteCompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = self.tasks.filter({ $0.listId == self.currentListId && $0.completed == true }).sorted(by: { $0.dateCompleted! > $1.dateCompleted! })
        
        for index in indexes {
            let task = taskList[index]
            let tasks = self.tasks.filter { $0.id != task.id }
            DataProvider().updateTasks(tasks)
            self.tasks = self.tasks.filter { $0.id != task.id }
        }
    }
    
    func unCompletedTasksSection() -> some View {
        return ForEach(getTaskListItems(completed: false), id: \.id) { task in
            TaskItemView(task: TaskObservable(task: task), tasks: self.$tasks)
        }
        .onDelete(perform: self.deleteUncompleted)
    }
    
    func completedTasksSection() -> some View {
        return ForEach(getTaskListItems(completed: true), id: \.id) { task in
            TaskItemView(task: TaskObservable(task: task), tasks: self.$tasks)
        }
        .onDelete(perform: self.deleteCompleted)
    }
    
    func addItem(){
        self.tasks.append(Task(listId: self.currentListId))
    }
    
    func getListName(currentListId: String) -> String {
        if currentListId == "" {
            return "Inbox"
        } else {
            return self.lists.filter {
                $0.id == currentListId
            }[0].name
        }
    }
    
    func navigationBarLeadingItem() -> some View {
        return Button(action: {
            self.showSheetType = "lists"
        }, label: {
            Image(systemName: "tray.2")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .font(Font.title.weight(.light))
            .frame(width: 20, height: 20)
        })
    }
    
    func navigationBarTrailingItem() -> some View {
        return Button(action: self.addItem, label: {
            Image(systemName: "plus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .font(Font.title.weight(.light))
            .frame(width: 20, height: 20)
        })
    }
    
    var body: some View {
        let showSheet = Binding(
            get: { () -> Bool in
                if self.showSheetType != "" {
                    return true
                }
                
                return false
            },
            set: {
                if !$0 {
                    self.showSheetType = ""
                }
            })
        
        NavigationView {
            ZStack(alignment: .top) {
                Picker("", selection: self.$currentTab) {
                    Text("To-do").tag("todo")
                    Text("Done").tag("done")
                }
                .labelsHidden()
                .frame(maxWidth: .infinity, maxHeight: 40)
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 0)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .padding(.bottom, 10)
                .onChange(of: self.currentTab) { newValue in
                    print("TAB CHANGED")
                    self.tasks = DataProvider().getTasks()
                }
            
                ZStack(alignment: .bottom) {
                    List {
                        if self.currentTab == "todo" {
                            unCompletedTasksSection()
                        } else {
                            completedTasksSection()
                        }
                    }
                    .id(self.counter)
                    .listStyle(PlainListStyle())
                    .offset(y: 45)
                }
            }
                
            .navigationBarTitle(getListName(currentListId: self.currentListId), displayMode: .inline)
            .navigationBarItems(leading: navigationBarLeadingItem(), trailing: navigationBarTrailingItem())
            .navigationBarColor(colorScheme == .dark ? .black : .white)
            .sheet(isPresented: showSheet, content: {
                if self.showSheetType == "lists" {
                    ListsView(lists: self.$lists, tasks: self.$tasks, currentListId: self.$currentListId, showSheet: showSheet)
                }
            })
            .onAppear {
                if self.tasks.isEmpty {
                    self.tasks = DataProvider().getTasks()
                }
                
                if self.lists.isEmpty {
                    self.lists = DataProvider().getLists()
                }
                
                self.counter += 1
            }
        }
    }
}

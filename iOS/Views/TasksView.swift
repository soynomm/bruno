import SwiftUI

struct TasksView: View {
    @ObservedObject var db: DatabaseObservable
    @Environment(\.colorScheme) var colorScheme
    @State var currentTab: String = "todo"
    @State var currentListId: String = ""
    @State var showSheetType: String = ""
    @State var counter: Int = 0

    func getTaskListItems(completed: Bool) -> [Task] {
        let taskList = db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.currentListId
        }
        
        return taskList.filter {
            $0.completed == completed
        }
    }
    
    func deleteUncompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.currentListId && $0.completed == false
        }
        
        for index in indexes {
            let task = taskList[index]
            db.tasks = db.tasks.filter { $0.id != task.id }
        }
    }
    
    func deleteCompleted(at offsets: IndexSet) -> Void {
        let indexes = Array(offsets)
        let taskList = db.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }).filter {
            $0.listId == self.currentListId && $0.completed == true
        }
        
        for index in indexes {
            let task = taskList[index]
            db.tasks = db.tasks.filter { $0.id != task.id }
        }
    }
    
    func unCompletedTasksSection() -> some View {
        return ForEach(getTaskListItems(completed: false), id: \.id) { task in
            TaskItemView(task: TaskObservable(task: task, db: db), db: db, subTasks: db.subTasks)
        }
        .onDelete(perform: self.deleteUncompleted)
    }
    
    func completedTasksSection() -> some View {
        return ForEach(getTaskListItems(completed: true), id: \.id) { task in
            TaskItemView(task: TaskObservable(task: task, db: db), db: db, subTasks: db.subTasks)
        }
        .onDelete(perform: self.deleteCompleted)
    }
    
    func addItem(){
        db.tasks.append(Task(listId: self.currentListId))
    }
    
    func getListName(currentListId: String) -> String {
        if currentListId == "" {
            return "Inbox"
        } else {
            return db.lists.filter {
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
        return Button(action: {
            self.showSheetType = "settings"
        }, label: {
            Image(systemName: "gearshape")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .font(Font.title.weight(.light))
            .frame(width: 20, height: 20)
        })
    }
    
    func purgingTasksConfiguration() -> ConfigurationObservable {
        let configuration = self.db.configuration.first { $0.key == "purgingTasks" }
        
        if configuration != nil {
            return ConfigurationObservable(configuration: configuration!, db: self.db)
        } else {
            return ConfigurationObservable(configuration: Configuration(key: "purgingTasks", value: "yes"), db: self.db)
        }
    }
    
    func purgingTasksIntervalConfiguration() -> ConfigurationObservable {
        let configuration = self.db.configuration.first { $0.key == "purgingTasksInterval" }
        
        if configuration != nil {
            return ConfigurationObservable(configuration: configuration!, db: self.db)
        } else {
            return ConfigurationObservable(configuration: Configuration(key: "purgingTasksInterval", value: "3months"), db: self.db)
        }
    }
    
    func isBottom() -> Bool {
        if #available(iOS 11.0, *), let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first, keyWindow.safeAreaInsets.bottom > 0 {
            return true
        }
        
        return false
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
            
                ZStack(alignment: .bottom) {
                    List {
                        if self.currentTab == "todo" {
                            unCompletedTasksSection()
                        } else {
                            completedTasksSection()
                        }
                        
                        // Filler for the add task button
                        Rectangle().fill(colorScheme == .dark ? Color.black : Color.white).frame(width: 1200, height: 75).offset(x: -30, y: 10).edgesIgnoringSafeArea(.all)
                    }
                    .id(self.counter)
                    .listStyle(PlainListStyle())
                    .offset(y: 45)
                    
                    if isBottom() {
                        Button(action: self.addItem, label: {
                            Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.light))
                            .frame(width: 18, height: 18)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .padding(EdgeInsets(top: 13, leading: 23, bottom: 13, trailing: 23))
                                .background(Circle().fill(colorScheme == .dark ? AppConfiguration().primaryColorDark : AppConfiguration().primaryColor).shadow(color: colorScheme == .dark ? .black : .white, radius: 26, x: 0, y: 3))
                        })
                    } else {
                        Button(action: self.addItem, label: {
                            Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(Font.title.weight(.light))
                            .frame(width: 18, height: 18)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .padding(EdgeInsets(top: 13, leading: 23, bottom: 13, trailing: 23))
                            .background(Circle().fill(colorScheme == .dark ? AppConfiguration().primaryColorDark : AppConfiguration().primaryColor).shadow(color: colorScheme == .dark ? .black : .white, radius: 26, x: 0, y: 3))
                        })
                        .offset(y: -25)
                    }
                }
            }
                
            .navigationBarTitle(getListName(currentListId: self.currentListId), displayMode: .inline)
            .navigationBarItems(leading: navigationBarLeadingItem(), trailing: navigationBarTrailingItem())
            .navigationBarColor(colorScheme == .dark ? .black : .white)
            .sheet(isPresented: showSheet, content: {
                if self.showSheetType == "lists" {
                    ListsView(db: self.db, currentListId: self.$currentListId, showSheet: showSheet)
                }
                
                if self.showSheetType == "settings" {
                    SettingsView(purgingTasks: purgingTasksConfiguration(), purgingTasksInterval: purgingTasksIntervalConfiguration())
                }
            })
        }
        .id(self.counter)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            self.counter += 1
        }
    }
}

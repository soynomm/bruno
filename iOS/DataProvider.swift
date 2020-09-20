import Foundation

class DataProvider {
    var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!

    func initialize() {
        guard NSData(contentsOf: documentsDirectory.appendingPathComponent("db.json")) != nil else {
            let data = Database()
            let json = data.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
            return
        }
    }
    
    public func read() -> Database {
        self.initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        let fileContentsData = try? decoder.decode(Database.self, from: Data(fileContents!.utf8))

        return fileContentsData ?? Database()
    }
    
    public func write(_ db: Database) {
        DispatchQueue.global(qos: .background).async {
            var database = db
            let timeIntervalMonth: Double = 43800 * 60
            let timeInterval: Double = timeIntervalMonth * 6
            var okTasks: [Task] = []
            
            for task in db.tasks {
                if task.completed == false && task.dateCompleted == nil {
                    okTasks.append(task)
                }
                
                if task.completed == true && task.dateCompleted != nil && task.dateCompleted!.addingTimeInterval(timeInterval) > Date() {
                    okTasks.append(task)
                }
            }
            
            database.tasks = okTasks
            let json = database.convertToString!
            try? json.write(to: self.documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        }
    }
    
    public func getTasks() -> [Task] {
        return self.read().tasks
    }
    
    public func getSubTasks(_ parentId: String) -> [SubTask] {
        return self.read().subTasks.filter { $0.parentId == parentId }
    }
    
    public func getLists() -> [TaskList] {
        return self.read().lists
    }
    
    public func getConfiguration(_ key: String) -> Configuration? {
        let data = self.read()
        let index = data.configuration.firstIndex { $0.key == key }
        
        if index != nil {
            print("configuration exist")
            print(data.configuration[index!])
            return data.configuration[index!]
        } else {
            print("configuration does not exist")
            return nil
        }
    }
    
    public func updateTask(_ task: TaskObservable) {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let task = Task(id: task.id, listId: task.listId, name: task.name, notes: task.notes, starred: task.starred, completed: task.completed, dateCreated: task.dateCreated, dateCompleted: task.dateCompleted, dueDate: task.dueDate, dueDateSet: task.dueDateSet, dueDateReminderSet: task.dueDateReminderSet, dueDateReminderInterval: task.dueDateReminderInterval)
            let index = data.tasks.firstIndex { $0.id == task.id }
            
            if index != nil {
                print("Updating task:")
                print(task)
                data.tasks[index!] = task
            } else {
                print("Creating task:")
                print(task)
                data.tasks.append(task)
            }
            
            self.write(data)
        }
    }
    
    public func updateTasks(_ tasks: [Task]) {
        DispatchQueue.global(qos: .background).async {
            print("Updating tasks")
            var data = self.read()
            data.tasks = tasks
            self.write(data)
        }
    }
    
    public func updateSubTask(_ task: SubTask) {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let index = data.subTasks.firstIndex { $0.id == task.id }
            
            if index != nil {
                print("Updating subtask:")
                print(task)
                data.subTasks[index!] = task
            } else {
                print("Creating subtask:")
                print(task)
                data.subTasks.append(task)
            }
            
            self.write(data)
        }
    }
    
    public func updateSubTasks(_ tasks: [SubTask]) {
        DispatchQueue.global(qos: .background).async {
            print("Updating subtasks")
            var data = self.read()
            data.subTasks = tasks
            self.write(data)
        }
    }
    
    public func updateList(_ list: TaskListObservable) {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let list = TaskList(id: list.id, name: list.name)
            let index = data.lists.firstIndex { $0.id == list.id }
            
            if index != nil {
                print("Updating list")
                print(list)
                data.lists[index!] = list
            } else {
                print("Creating list")
                print(list)
                data.lists.append(list)
            }
            
            self.write(data)
        }
    }
    
    public func updateLists(_ lists: [TaskList]) {
        DispatchQueue.global(qos: .background).async {
            print("Updating lists")
            var data = self.read()
            data.lists = lists
            self.write(data)
        }
    }
    
    public func updateConfiguration(_ configuration: Configuration) {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let index = data.configuration.firstIndex { $0.key == configuration.key }
            
            if index != nil {
                print("Updating configuration")
                print(configuration)
                data.configuration[index!] = configuration
            } else {
                print("Creating configuration")
                print(configuration)
                data.configuration.append(configuration)
            }
            
            self.write(data)
        }
    }
}

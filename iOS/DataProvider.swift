import Foundation

// DataProvider is responsible for any-and-all data manipulation that happens between
// the stored data on disk and the data in memory.
class DataProvider
{
    // Get the URL to the documents directory
    // To be used to access the database file.
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
    // Set the database file name.
    let dataFile = "db.json"

    // Checks if the `dataFile` exists, and if it doesn't it will create it.
    func initialize()
    {
        guard NSData(contentsOf: documentsDirectory.appendingPathComponent(self.dataFile)) != nil else {
            let data = Database()
            let json = data.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent(self.dataFile), atomically: true, encoding: .utf8)
            return
        }
    }
    
    // Read the `dataFile` from disk and return it, and if it can't parse it
    // then return a new instance of Database instead.
    public func read() -> Database
    {
        self.initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent(self.dataFile), encoding: .utf8)
        let decoder = JSONDecoder()
        let fileContentsData = try? decoder.decode(Database.self, from: Data(fileContents!.utf8))

        return fileContentsData ?? Database()
    }
    
    // Write a instance of Database to the disk.
    public func write(_ db: Database)
    {
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
    
    // Read the database from the disk and return [Task].
    public func getTasks() -> [Task]
    {
        return self.read().tasks
    }
    
    // Read the database from the disk and return [SubTask].
    public func getSubTasks(_ parentId: String) -> [SubTask]
    {
        return self.read().subTasks.filter { $0.parentId == parentId }
    }
    
    // Read the database from the disk and return [TaskList].
    public func getLists() -> [TaskList]
    {
        return self.read().lists
    }
    
    // Read the database from the disk and return an optional Configuration
    public func getConfiguration(_ key: String) -> Configuration?
    {
        let data = self.read()
        let index = data.configuration.firstIndex { $0.key == key }
        
        if index != nil {
            return data.configuration[index!]
        } else {
            return nil
        }
    }
    
    // Updates a specific task at its index and writes the updated instance of Database to the disk.
    public func updateTask(_ task: TaskObservable)
    {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let task = Task(id: task.id, listId: task.listId, name: task.name, notes: task.notes, starred: task.starred, completed: task.completed, dateCreated: task.dateCreated, dateCompleted: task.dateCompleted, dueDate: task.dueDate, dueDateSet: task.dueDateSet, dueDateReminderSet: task.dueDateReminderSet, dueDateReminderInterval: task.dueDateReminderInterval)
            let index = data.tasks.firstIndex { $0.id == task.id }
            
            if index != nil {
                data.tasks[index!] = task
            } else {
                data.tasks.append(task)
            }
            
            self.write(data)
        }
    }
    
    // Updates all of the tasks and writes the updated instance of Database to the disk.
    public func updateTasks(_ tasks: [Task])
    {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            data.tasks = tasks
            self.write(data)
        }
    }
    
    // Updates a specific subtask at its index and writes the updated instance of Database to the disk.
    public func updateSubTask(_ task: SubTask)
    {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let index = data.subTasks.firstIndex { $0.id == task.id }
            
            if index != nil {
                data.subTasks[index!] = task
            } else {
                data.subTasks.append(task)
            }
            
            self.write(data)
        }
    }
    
    // Updates all of the subtasks and writes the updated instance of Database to the disk.
    public func updateSubTasks(_ tasks: [SubTask])
    {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            data.subTasks = tasks
            self.write(data)
        }
    }
    
    // Updates a specific list at its index and writes the updated instance of Database to the disk.
    public func updateList(_ list: TaskListObservable)
    {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let list = TaskList(id: list.id, name: list.name)
            let index = data.lists.firstIndex { $0.id == list.id }
            
            if index != nil {
                data.lists[index!] = list
            } else {
                data.lists.append(list)
            }
            
            self.write(data)
        }
    }
    
    // Updates all of the lists and writes the updated instance of Database to the disk.
    public func updateLists(_ lists: [TaskList])
    {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            data.lists = lists
            self.write(data)
        }
    }
    
    // Updates a specific configuration at its index and writes the updated instance of Database to the disk.
    public func updateConfiguration(_ configuration: Configuration)
    {
        DispatchQueue.global(qos: .background).async {
            var data = self.read()
            let index = data.configuration.firstIndex { $0.key == configuration.key }
            
            if index != nil {
                data.configuration[index!] = configuration
            } else {
                data.configuration.append(configuration)
            }
            
            self.write(data)
        }
    }
}

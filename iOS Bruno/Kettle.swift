import Foundation

struct KettleConfiguration {
    var throttlerDelay = 0.3
    var noteThrottler = 1.0
}

struct Task: Codable, Hashable {
    var id: String = UUID().uuidString
    var listId: String = ""
    var name: String = ""
    var notes: String = ""
    var completed: Bool = false
    var dateCreated = Date()
    var dateReminder = Date()
    var dateReminderSet: Bool = false
}

class TaskObservable: ObservableObject {
    var id: String
    var db: DatabaseObservable
    let throttler = Throttler(minimumDelay: KettleConfiguration().throttlerDelay)
    let noteThrottler = Throttler(minimumDelay: KettleConfiguration().noteThrottler)

    @Published var listId: String {
        didSet {
            setListId(oldValue)
        }
    }
    @Published var name: String {
        didSet {
            setName(oldValue)
        }
    }
    @Published var notes: String {
        didSet {
            setNotes(oldValue)
        }
    }
    @Published var completed: Bool {
        didSet {
            setCompleted(oldValue)
        }
    }
    @Published var dateCreated: Date {
        didSet {
            setDateCreated(oldValue)
        }
    }
    @Published var dateReminder: Date {
        didSet {
            setDateReminder(oldValue)
        }
    }
    @Published var dateReminderSet: Bool {
        didSet {
            setDateReminderSet(oldValue)
        }
    }
    
    public init(task: Task, db: DatabaseObservable) {
        self.id = task.id
        self.db = db
        self.listId = task.listId
        self.name = task.name
        self.notes = task.notes
        self.completed = task.completed
        self.dateCreated = task.dateCreated
        self.dateReminder = task.dateReminder
        self.dateReminderSet = task.dateReminderSet
    }

    func setListId(_ oldValue: String) {
        if self.listId != oldValue {
            throttler.throttle {
                let index = self.db.tasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.tasks[index!].listId = self.listId
                }
            }
        }
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                let index = self.db.tasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.tasks[index!].name = self.name
                }
            }
        }
    }
    
    func setNotes(_ oldValue: String) {
        if self.notes != oldValue {
            noteThrottler.throttle {
                let index = self.db.tasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.tasks[index!].notes = self.notes
                }
            }
        }
    }
    
    func setCompleted(_ oldValue: Bool) {
        if self.completed != oldValue {
            throttler.throttle {
                let index = self.db.tasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.tasks[index!].completed = self.completed
                }
            }
        }
    }
    
    func setDateCreated(_ oldValue: Date) {
        if self.dateCreated != oldValue {
            throttler.throttle {
                let index = self.db.tasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.tasks[index!].dateCreated = self.dateCreated
                }
            }
        }
    }
    
    func setDateReminder(_ oldValue: Date) {
        if self.dateReminder != oldValue {
            throttler.throttle {
                let index = self.db.tasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.tasks[index!].dateReminder = self.dateReminder
                }
            }
        }
    }
    
    func setDateReminderSet(_ oldValue: Bool) {
        if self.dateReminderSet != oldValue {
            throttler.throttle {
                let index = self.db.tasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.tasks[index!].dateReminderSet = self.dateReminderSet
                }
            }
        }
    }
}

struct SubTask: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var parentId: String = ""
    var name: String = ""
    var completed: Bool = false
    var dateCreated = Date()
}

class SubTaskObservable: ObservableObject {
    var id: String
    let db: DatabaseObservable
    let throttler = Throttler(minimumDelay: KettleConfiguration().throttlerDelay)
    
    @Published var parentId: String {
        didSet {
            setParentId(oldValue)
        }
    }
    @Published var name: String {
        didSet {
            setName(oldValue)
        }
    }
    @Published var completed: Bool {
        didSet {
            setCompleted(oldValue)
        }
    }
    @Published var dateCreated: Date {
        didSet {
            setDateCreated(oldValue)
        }
    }
    
    public init(task: SubTask, db: DatabaseObservable) {
        self.id = task.id
        self.db = db
        self.parentId = task.parentId
        self.name = task.name
        self.completed = task.completed
        self.dateCreated = task.dateCreated
    }
    
    func setParentId(_ oldValue: String) {
        if self.parentId != oldValue {
            throttler.throttle {
                let index = self.db.subTasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.subTasks[index!].parentId = self.parentId
                }
            }
        }
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                let index = self.db.subTasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.subTasks[index!].name = self.name
                }
            }
        }
    }
    
    func setCompleted(_ oldValue: Bool) {
        if self.completed != oldValue {
            throttler.throttle {
                let index = self.db.subTasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.subTasks[index!].completed = self.completed
                }
            }
        }
    }
    
    func setDateCreated(_ oldValue: Date) {
        if self.dateCreated != oldValue {
            throttler.throttle {
                let index = self.db.subTasks.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.subTasks[index!].dateCreated = self.dateCreated
                }
            }
        }
    }
}

struct TaskList: Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
}

class TaskListObservable: ObservableObject {
    var id: String
    let db: DatabaseObservable
    let throttler = Throttler(minimumDelay: KettleConfiguration().throttlerDelay)

    @Published var name: String {
        didSet {
            setName(oldValue)
        }
    }
    
    public init(list: TaskList, db: DatabaseObservable) {
        self.id = list.id
        self.db = db
        self.name = list.name
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                let index = self.db.lists.firstIndex { $0.id == self.id }
                
                if index != nil {
                    self.db.lists[index!].name = self.name
                }
            }
        }
    }
}

struct Configuration: Codable, Hashable {
    var key: String
    var value: String
}

class ConfigurationObservable: ObservableObject {
    var key: String
    var db: DatabaseObservable
    let throttler = Throttler(minimumDelay: KettleConfiguration().throttlerDelay)
    @Published var value: String {
        didSet {
            setValue(oldValue)
        }
    }
    
    public init(configuration: Configuration, db: DatabaseObservable) {
        self.key = configuration.key
        self.db = db
        self.value = configuration.value
    }
    
    func configuration() -> Configuration {
        return Configuration(
            key: self.key,
            value: self.value
        )
    }
    
    func setValue(_ oldValue: String) {
        if self.value != oldValue {
            throttler.throttle {
                let index = self.db.configuration.firstIndex { $0.key == self.key }
                
                if index != nil {
                    self.db.configuration[index!].value = self.value
                }
            }
        }
    }
}

struct Database: Codable {
    var tasks: [Task] = []
    var subTasks: [SubTask] = []
    var lists: [TaskList] = []
    var configuration: [Configuration] = []
}

class DatabaseObservable: ObservableObject {
    @Published var tasks: [Task] {
        didSet {
            print("TASKS UPDATED")
        }
    }
    
    @Published var subTasks: [SubTask] {
        didSet {
            print("SUBTASKS UPDATED")
        }
    }
    
    @Published var lists: [TaskList] {
        didSet {
            print("LISTS UPDATED")
        }
    }
    
    @Published var configuration: [Configuration] {
        didSet {
            print("CONFIGURATION UPDATED")
        }
    }
    
    init(database: Database) {
        self.tasks = database.tasks
        self.subTasks = database.subTasks
        self.lists = database.lists
        self.configuration = database.configuration
    }
}


class Kettle {
    var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
    func initialize() {
        // If the file does not exist, let's create it
        guard NSData(contentsOf: documentsDirectory.appendingPathComponent("db.json")) != nil else {
            let data = Database()
            let json = data.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
            
            return
        }
    }
    
    func get() -> Database {
        self.initialize()
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        let fileContentsData = try? decoder.decode(Database.self, from: Data(fileContents!.utf8))
        return fileContentsData!
    }
    
    func write(_ db: DatabaseObservable) {
        let database = Database(tasks: db.tasks, subTasks: db.subTasks, lists: db.lists, configuration: db.configuration)
        let json = database.convertToString!
        try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
    }
}

extension Encodable {
    var convertToString: String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

class Throttler {
    private var workItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval

    init(minimumDelay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.minimumDelay = minimumDelay
        self.queue = queue
    }

    func throttle(_ block: @escaping () -> Void) {
        // Cancel any existing work item if it has not yet executed
        workItem.cancel()

        // Re-assign workItem with the new block task, resetting the previousRun time when it executes
        workItem = DispatchWorkItem() {
            [weak self] in
            self?.previousRun = Date()
            block()
        }

        // If the time since the previous run is more than the required minimum delay
        // => execute the workItem immediately
        // else
        // => delay the workItem execution by the minimum delay time
        let delay = previousRun.timeIntervalSinceNow > minimumDelay ? 0 : minimumDelay
        queue.asyncAfter(deadline: .now() + Double(delay), execute: workItem)
    }
}

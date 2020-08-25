import Foundation

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
    let throttler = KettleThrottler(minimumDelay: 0.5)
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
    
    public init(task: Task) {
        self.id = task.id
        self.listId = task.listId
        self.name = task.name
        self.notes = task.notes
        self.completed = task.completed
        self.dateCreated = task.dateCreated
        self.dateReminder = task.dateReminder
        self.dateReminderSet = task.dateReminderSet
    }
    
    func task() -> Task {
        return Task(
            id: self.id,
            listId: self.listId,
            name: self.name,
            notes: self.notes,
            completed: self.completed,
            dateCreated: self.dateCreated,
            dateReminder: self.dateReminder,
            dateReminderSet: self.dateReminderSet
        )
    }
    
    func setListId(_ oldValue: String) {
        if self.listId != oldValue {
            Kettle().updateTask(task())
        }
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                Kettle().updateTask(self.task())
            }
        }
    }
    
    func setNotes(_ oldValue: String) {
        if self.notes != oldValue {
            throttler.throttle {
                Kettle().updateTask(self.task())
            }
        }
    }
    
    func setCompleted(_ oldValue: Bool) {
        if self.completed != oldValue {
           Kettle().updateTask(task())
        }
    }
    
    func setDateCreated(_ oldValue: Date) {
        if self.dateCreated != oldValue {
           Kettle().updateTask(task())
        }
    }
    
    func setDateReminder(_ oldValue: Date) {
        if self.dateReminder != oldValue {
           Kettle().updateTask(task())
        }
    }
    
    func setDateReminderSet(_ oldValue: Bool) {
        if self.dateReminderSet != oldValue {
           Kettle().updateTask(task())
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
    let throttler = KettleThrottler(minimumDelay: 0.5)
    
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
    
    public init(task: SubTask) {
        self.id = task.id
        self.parentId = task.parentId
        self.name = task.name
        self.completed = task.completed
        self.dateCreated = task.dateCreated
    }
    
    func task() -> SubTask {
        return SubTask(
            id: self.id,
            parentId: self.parentId,
            name: self.name,
            completed: self.completed,
            dateCreated: self.dateCreated
        )
    }
    
    func setParentId(_ oldValue: String) {
        if self.parentId != oldValue {
            Kettle().updateSubTask(task())
        }
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                Kettle().updateSubTask(self.task())
            }
        }
    }
    
    func setCompleted(_ oldValue: Bool) {
        if self.completed != oldValue {
           Kettle().updateSubTask(task())
        }
    }
    
    func setDateCreated(_ oldValue: Date) {
        if self.dateCreated != oldValue {
           Kettle().updateSubTask(task())
        }
    }
}

struct TaskList: Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
}

class TaskListObservable: ObservableObject {
    var id: String
    let throttler = KettleThrottler(minimumDelay: 0.5)
    
    @Published var name: String {
        didSet {
            setName(oldValue)
        }
    }
    
    public init(list: TaskList) {
        self.id = list.id
        self.name = list.name
    }
    
    func list() -> TaskList {
        return TaskList(
            id: self.id,
            name: self.name
        )
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                Kettle().updateList(self.list())
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
    @Published var value: String {
        didSet {
            setValue(oldValue)
        }
    }
    
    public init(configuration: Configuration) {
        self.key = configuration.key
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
            Kettle().updateConfiguration(self.configuration())
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
    
    func addConfiguration(_ configuration: Configuration) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            
            if fileContentsData.configuration.filter({ $0.key == configuration.key }) == [] {
                fileContentsData.configuration.insert(configuration, at: 0)
                let json = fileContentsData.convertToString!
                try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateConfiguration(_ configuration: Configuration) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            let configurationIndex = fileContentsData.configuration.firstIndex { $0.key == configuration.key }
            fileContentsData.configuration[configurationIndex!] = configuration
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }

    func addTask(_ task: Task) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            fileContentsData.tasks.append(task)
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateTask(_ task: Task) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            let taskIndex = fileContentsData.tasks.firstIndex { $0.id == task.id }
            fileContentsData.tasks[taskIndex!] = task
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteTask(_ task: Task) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        print("DELETING TASK:")
        print(task)
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            fileContentsData.tasks = fileContentsData.tasks.filter { $0.id != task.id }
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addSubTask(_ task: SubTask) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            fileContentsData.subTasks.append(task)
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateSubTask(_ task: SubTask) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            let taskIndex = fileContentsData.subTasks.firstIndex { $0.id == task.id }
            fileContentsData.subTasks[taskIndex!] = task
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteSubTask(_ task: SubTask) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            fileContentsData.subTasks = fileContentsData.subTasks.filter { $0.id != task.id }
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addList(_ list: TaskList) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            fileContentsData.lists.append(list)
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateList(_ list: TaskList) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            let listIndex = fileContentsData.lists.firstIndex { $0.id == list.id }
            fileContentsData.lists[listIndex!] = list
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteList(_ list: TaskList) {
        Kettle().initialize()
        
        let fileContents = try? String(contentsOf: documentsDirectory.appendingPathComponent("db.json"), encoding: .utf8)
        let decoder = JSONDecoder()
        
        do {
            var fileContentsData = try decoder.decode(Database.self, from: Data(fileContents!.utf8))
            fileContentsData.lists = fileContentsData.lists.filter { $0.id != list.id }
            let json = fileContentsData.convertToString!
            try? json.write(to: documentsDirectory.appendingPathComponent("db.json"), atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
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

class KettleObserver: ObservableObject {
    @Published var db: Database = Database()
    @Published var loaded: Bool = false
    var files: [URL] = []
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    private lazy var folderMonitor = KettleObserverMonitor(url: self.url)
    
    init() {
        Kettle().initialize()
        
        folderMonitor.folderDidChange = { [weak self] in
            self?.handleChanges()
        }
        
        folderMonitor.start()
        self.handleChanges()
    }
    
    func handleChanges() {
        let files = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)) ?? []
        DispatchQueue.main.async {
            for file in files {
                // Our DB
                if file.absoluteString.contains("db.json") {
                    self.loaded = true
                    let data = Kettle().get()
                    /*
                    if data != nil {
                        self.db = data!
                    }
                    */
                }
            }
        }
    }

}

extension URL: Identifiable {
    public var id: String { return lastPathComponent }
}

class KettleObserverMonitor {
    // A file descriptor for the monitored directory.
    private var monitoredFolderFileDescriptor: CInt = -1
    
    // A dispatch source to monitor a file descriptor created from the directory.
    private var folderMonitorSource: DispatchSourceFileSystemObject?
    
    // A dispatch queue used for sending file changes in the directory.
    private let folderMonitorQueue = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)
    
    // Callback for when folder changed.
    var folderDidChange: (() -> Void)?
    
    // The location
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    // Start monitoring the folder for changes
    func start() {
        guard folderMonitorSource == nil && monitoredFolderFileDescriptor == -1 else {
            return
        }
        
        // Open the folder referenced by the URL for monitoring only.
        monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)
        
        // Define a dispatch source monitoring the folder for additions, deletions and renamings.
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor, eventMask: .write, queue: folderMonitorQueue)
        
        // Define the block to call when a file change is detected.
        folderMonitorSource?.setEventHandler { [weak self] in
            self?.folderDidChange?()
        }
        
        // Define a cancel handler to ensure the directory is closed when the source is cancelled.
        folderMonitorSource?.setCancelHandler { [weak self] in
            guard let self = self else { return }
            close(self.monitoredFolderFileDescriptor)
            self.monitoredFolderFileDescriptor = -1
            self.folderMonitorSource = nil
        }
        
        // Start monitoring the directory via the source.
        folderMonitorSource?.resume()
    }
    
    // Stop monitoring the folder for changes.
    func stop() {
        folderMonitorSource?.cancel()
    }
}

class KettleThrottler {
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

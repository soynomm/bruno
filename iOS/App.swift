import Foundation
import SwiftUI

struct AppConfiguration {
    var throttlerDelay = 0.3
    var noteThrottler = 2.0
    var debug = true
    var primaryColorUI = UIColor(red: 0.86, green: 0.00, blue: 0.36, alpha: 1.00)
    var primaryColorUIDark = UIColor(red: 1.00, green: 0.15, blue: 0.51, alpha: 1.00)
    var primaryColor = Color(UIColor(red: 0.86, green: 0.00, blue: 0.36, alpha: 1.00))
    var primaryColorDark = Color(UIColor(red: 1.00, green: 0.15, blue: 0.51, alpha: 1.00))
}

struct AppFeatures {
    var schedule = false
}

class App {
    public func clearNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    public func setNotification(id: String, date: Date, contents: String, block: @escaping () -> Void) {
        self.clearNotification(id: id)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                let content = UNMutableNotificationContent()
                content.title = "Woof-woof"
                content.body = contents
                content.sound = UNNotificationSound.default
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request)
            } else {
                block()
            }
        }
    }
}

struct Task: Codable, Hashable {
    var id: String = UUID().uuidString
    var listId: String = ""
    var name: String = ""
    var notes: String = ""
    var starred: Bool = false
    var completed: Bool = false
    var dateCreated = Date()
    var dateCompleted: Date? = nil
    var dueDate = Date()
    var dueDateSet: Bool = false
    var dueDateReminderSet: Bool = false
    var dueDateReminderInterval: String = ""
    var misc: [String: String] = [:]
}

class TaskObservable: ObservableObject {
    var id: String
    let throttler = Throttler(minimumDelay: AppConfiguration().throttlerDelay)
    let noteThrottler = Throttler(minimumDelay: AppConfiguration().noteThrottler)

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
    @Published var starred: Bool {
        didSet {
            setStarred(oldValue)
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
    @Published var dateCompleted: Date?
    
    @Published var dueDate: Date {
        didSet {
            setDueDate(oldValue)
        }
    }
    @Published var dueDateSet: Bool {
        didSet {
            setDueDateSet(oldValue)
        }
    }
    @Published var dueDateReminderSet: Bool {
        didSet {
            setDueDateReminderSet(oldValue)
        }
    }
    @Published var dueDateReminderInterval: String {
        didSet {
            setDueDateReminderInterval(oldValue)
        }
    }
    
    public init(task: Task) {
        self.id = task.id
        self.listId = task.listId
        self.name = task.name
        self.notes = task.notes
        self.starred = task.starred
        self.completed = task.completed
        self.dateCreated = task.dateCreated
        
        if task.dateCompleted != nil {
            self.dateCompleted = task.dateCompleted!
        } else {
            self.dateCompleted = nil
        }

        self.dueDate = task.dueDate
        self.dueDateSet = task.dueDateSet
        self.dueDateReminderSet = task.dueDateReminderSet
        self.dueDateReminderInterval = task.dueDateReminderInterval
    }

    func setListId(_ oldValue: String) {
        if self.listId != oldValue {
            throttler.throttle {
                DataProvider().updateTask(self)
            }
        }
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                DataProvider().updateTask(self)
            }
        }
    }
    
    func setNotes(_ oldValue: String) {
        if self.notes != oldValue {
            noteThrottler.throttle {
                DataProvider().updateTask(self)
            }
        }
    }
    
    func setStarred(_ oldValue: Bool) {
        if self.starred != oldValue {
            throttler.throttle {
                DataProvider().updateTask(self)
            }
        }
    }
    
    func setCompleted(_ oldValue: Bool) {
        if self.completed != oldValue {
            throttler.throttle {
                let task = self
                task.dateCompleted = Date()
                DataProvider().updateTask(task)
            }
        }
    }
    
    func setDateCreated(_ oldValue: Date) {
        if self.dateCreated != oldValue {
            throttler.throttle {
                DataProvider().updateTask(self)
            }
        }
    }
    
    func setDueDate(_ oldValue: Date) {
        if self.dueDateReminderSet {
            App().setNotification(id: self.id, date: self.dueDate, contents: self.name) {
                self.dueDateReminderSet = false
            }
        }
        
        DataProvider().updateTask(self)
    }
    
    func setDueDateSet(_ oldValue: Bool) {
        throttler.throttle {
            DataProvider().updateTask(self)
        }
    }
    
    func setDueDateReminderSet(_ oldValue: Bool) {
        if self.dueDateReminderSet {
            App().setNotification(id: self.id, date: self.dueDate, contents: self.name) {
                self.dueDateReminderSet = false
            }
        } else {
            App().clearNotification(id: self.id)
        }
        
        DataProvider().updateTask(self)
    }
    
    func setDueDateReminderInterval(_ oldValue: String) {
        if self.dueDateReminderInterval != oldValue {
            throttler.throttle {
                DataProvider().updateTask(self)
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
    var misc: [String: String] = [:]
}

class SubTaskObservable: ObservableObject {
    var id: String
    let throttler = Throttler(minimumDelay: AppConfiguration().throttlerDelay)
    
    @Published var parentId: String {
        didSet {
            composeTask(self)
        }
    }
    @Published var name: String {
        didSet {
            composeTask(self)
        }
    }
    @Published var completed: Bool {
        didSet {
            composeTask(self)
        }
    }
    @Published var dateCreated: Date {
        didSet {
            composeTask(self)
        }
    }
    
    public init(task: SubTask) {
        self.id = task.id
        self.parentId = task.parentId
        self.name = task.name
        self.completed = task.completed
        self.dateCreated = task.dateCreated
    }
    
    func composeTask(_ task: SubTaskObservable) {
        throttler.throttle {
            DataProvider().updateSubTask(SubTask(id: task.id, parentId: task.parentId, name: task.name, completed: task.completed, dateCreated: task.dateCreated))
        }
    }
}

struct TaskList: Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var misc: [String: String] = [:]
}

class TaskListObservable: ObservableObject {
    var id: String
    let throttler = Throttler(minimumDelay: AppConfiguration().throttlerDelay)

    @Published var name: String {
        didSet {
            setName(oldValue)
        }
    }
    
    public init(list: TaskList) {
        self.id = list.id
        self.name = list.name
    }
    
    func setName(_ oldValue: String) {
        if self.name != oldValue {
            throttler.throttle {
                DataProvider().updateList(self)
            }
        }
    }
}

struct Configuration: Codable, Hashable {
    var key: String
    var value: String
    var misc: [String: String] = [:]
}

class ConfigurationObservable: ObservableObject {
    var key: String
    let throttler = Throttler(minimumDelay: AppConfiguration().throttlerDelay)
    
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
        DataProvider().updateConfiguration(self.configuration())
    }
}

struct Database: Codable {
    var tasks: [Task] = []
    var subTasks: [SubTask] = []
    var lists: [TaskList] = []
    var configuration: [Configuration] = []
    var syncDate: Date? = nil
    var misc: [String: String] = [:]
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


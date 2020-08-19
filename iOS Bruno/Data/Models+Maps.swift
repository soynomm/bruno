import Foundation
import SwiftUI
import RealmSwift

protocol UUIDIdentifiable: Identifiable { var id:String { get } }
protocol Initializable { init() }


// MARK: - Backing Realm Data Object
class RealmListModel: Object, UUIDIdentifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class RealmTaskModel: Object, UUIDIdentifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var listId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var completed: Bool = false
    @objc dynamic var dateCreated = Date()
    @objc dynamic var dateReminder = Date()
    @objc dynamic var dateReminderSet: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class RealmSubTaskModel: Object, UUIDIdentifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var parentId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var completed: Bool = false
    @objc dynamic var dateCreated = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class RealmUserConfigurationModel: Object, UUIDIdentifiable {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var value: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// MARK: - Abstracted Data Struct which is what is presented with the UI
struct TaskListModel: Equatable {
    var id: String = UUID().uuidString
    var name: String = ""
}

struct TaskModel: Equatable {
    var id: String = UUID().uuidString
    var listId: String = ""
    var name: String = ""
    var notes: String = ""
    var completed: Bool = false
    var dateCreated = Date()
    var dateReminder = Date()
    var dateReminderSet: Bool = false
}

struct SubTaskModel: Equatable {
    var id: String = UUID().uuidString
    var parentId: String = ""
    var name: String = ""
    var completed: Bool = false
    var dateCreated = Date()
}

struct UserConfigurationModel: Equatable {
    var id: String = UUID().uuidString
    var value: String = ""
}

// MARK: - Map Between the Two

protocol RealmConvertible where Self:Equatable & UUIDIdentifiable & Initializable {
    associatedtype RealmType: Object & UUIDIdentifiable
    
    func realmMap() -> RealmType
    init(_ dest:RealmType)
}

// Dynamic Realm Binding for live data editing

extension RealmConvertible {
    func realmBinding() -> Binding<Self> {
        let h = RealmHelper()
        return Binding<Self>(get: {
            if let r = h.get(self.realmMap()) {
                // get the latest realm version for most uptodate data and map back to abstracted structs on init
                return Self(r)
            } else {
                // otherwise return self as it's the most uptodate version of the data struct
                return self
            }
        }, set: h.updateConvertible)
    }
}

extension RealmListModel {
    convenience init(_ obj: TaskListModel) {
        self.init()
        self.id = obj.id
        self.name = obj.name
    }
}

extension RealmTaskModel {
    convenience init(_ obj: TaskModel) {
        self.init()
        self.id = obj.id
        self.listId = obj.listId
        self.name = obj.name
        self.notes = obj.notes
        self.completed = obj.completed
        self.dateCreated = obj.dateCreated
        self.dateReminder = obj.dateReminder
        self.dateReminderSet = obj.dateReminderSet
    }
}

extension RealmSubTaskModel {
    convenience init(_ obj: SubTaskModel) {
        self.init()
        self.id = obj.id
        self.parentId = obj.parentId
        self.name = obj.name
        self.completed = obj.completed
        self.dateCreated = obj.dateCreated
    }
}

extension RealmUserConfigurationModel {
    convenience init(_ obj: UserConfigurationModel) {
        self.init()
        self.id = obj.id
        self.value = obj.value
    }
}

extension TaskListModel: RealmConvertible {
    func realmMap() -> RealmListModel {
        RealmListModel(self)
    }
    
    init(_ obj: RealmListModel) {
        self.id = obj.id
        self.name = obj.name
    }
}

extension TaskModel: RealmConvertible {
    func realmMap() -> RealmTaskModel {
        RealmTaskModel(self)
    }
    
    init(_ obj: RealmTaskModel) {
        self.id = obj.id
        self.listId = obj.listId
        self.name = obj.name
        self.notes = obj.notes
        self.completed = obj.completed
        self.dateCreated = obj.dateCreated
        self.dateReminder = obj.dateReminder
        self.dateReminderSet = obj.dateReminderSet
    }
}

extension SubTaskModel: RealmConvertible {
    func realmMap() -> RealmSubTaskModel {
        RealmSubTaskModel(self)
    }
    
    init(_ obj: RealmSubTaskModel) {
        self.id = obj.id
        self.parentId = obj.parentId
        self.name = obj.name
        self.completed = obj.completed
        self.dateCreated = obj.dateCreated
    }
}

extension UserConfigurationModel: RealmConvertible {
    func realmMap() -> RealmUserConfigurationModel {
        RealmUserConfigurationModel(self)
    }
    
    init(_ obj: RealmUserConfigurationModel) {
        self.id = obj.id
        self.value = obj.value
    }
}

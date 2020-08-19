import Combine
import RealmSwift

final class DataStore: ObservableObject {
    private var listCancellable: AnyCancellable?
    private var taskCancellable: AnyCancellable?
    private var userConfigurationCancellable: AnyCancellable?
    private(set) var listDB = DataObservable<TaskListModel>()
    private(set) var taskDB = DataObservable<TaskModel>()
    private(set) var userDB = DataObservable<UserConfigurationModel>()
    
    @Published private(set) var lists: [TaskListModel] = []
    @Published private(set) var tasks: [TaskModel] = []
    @Published private(set) var configs: [UserConfigurationModel] = []
    
    init() {
        listDB = DataObservable<TaskListModel>()
        taskDB = DataObservable<TaskModel>()
        userDB = DataObservable<UserConfigurationModel>()
        listCancellable = listDB.$items.assign(to: \.lists, on: self)
        taskCancellable = taskDB.$items.assign(to: \.tasks, on: self)
        userConfigurationCancellable = userDB.$items.assign(to: \.configs, on: self)
    }
}

import Combine
import RealmSwift

final class DataStore: ObservableObject {
    private var listCancellable: AnyCancellable?
    private var taskCancellable: AnyCancellable?
    private var subTaskCancellable: AnyCancellable?
    private var userConfigurationCancellable: AnyCancellable?
    private(set) var listDB = DataObservable<TaskListModel>()
    private(set) var taskDB = DataObservable<TaskModel>()
    private(set) var subTaskDB = DataObservable<SubTaskModel>()
    private(set) var userDB = DataObservable<UserConfigurationModel>()
    
    @Published private(set) var lists: [TaskListModel] = []
    @Published private(set) var tasks: [TaskModel] = []
    @Published private(set) var subTasks: [SubTaskModel] = []
    @Published private(set) var configs: [UserConfigurationModel] = []
    
    init() {
        listDB = DataObservable<TaskListModel>()
        taskDB = DataObservable<TaskModel>()
        subTaskDB = DataObservable<SubTaskModel>()
        userDB = DataObservable<UserConfigurationModel>()
        listCancellable = listDB.$items.assign(to: \.lists, on: self)
        taskCancellable = taskDB.$items.assign(to: \.tasks, on: self)
        subTaskCancellable = subTaskDB.$items.assign(to: \.subTasks, on: self)
        userConfigurationCancellable = userDB.$items.assign(to: \.configs, on: self)
    }
}

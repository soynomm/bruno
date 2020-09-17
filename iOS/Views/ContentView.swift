import SwiftUI

struct ContentWelcomeView: View {
	@ObservedObject var db: DatabaseObservable
	@ObservedObject var isWelcomeScreenConfiguration: ConfigurationObservable
	@Environment(\.colorScheme) var colorScheme
	var onlyLogo: Bool = false
	
	func disableWelcomeScreen() -> Void {
		isWelcomeScreenConfiguration.value = "no"
	}
	
	var body: some View {
		VStack {
			Image("Logo")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 100, height: 100)
			
			if !onlyLogo {
				Text("Hi! I'm Bruno, your best friend when it comes to getting things done.")
				.padding(20)
				.multilineTextAlignment(.center)
				
				Button(action: {
					self.disableWelcomeScreen()
				}, label: {
					Text("Let's do it!")
					.foregroundColor(colorScheme == .dark ? AppConfiguration().primaryColorDark : AppConfiguration().primaryColor)
				})
				.padding(.top, 20)
			}
			
		}
		.padding(20)
	}
}

struct ContentRegularView: View {
	@ObservedObject var db: DatabaseObservable
	@Environment(\.colorScheme) var colorScheme
	@State var selectedView = 0
	
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

	var body: some View {
		if AppFeatures().schedule {
			TabView {
				TasksView(db: db)
				.tabItem {
					Image(systemName: "checkmark.circle")
					Text("Tasks")
				}.tag(0)

				ScheduleView(db: db)
				.tabItem {
					Image(systemName: "calendar")
					Text("Schedule")
				}.tag(1)
			}
			.accentColor(colorScheme == .dark ? AppConfiguration().primaryColorDark : AppConfiguration().primaryColor)
		} else {
			TasksView(db: db)
		}
	}
}

struct ContentView: View {
	@ObservedObject var db = DatabaseObservable(database: AppDatabase().get())

	func isWelcomeScreenConfiguration() -> ConfigurationObservable {
		let configuration = self.db.configuration.first { $0.key == "isWelcomeScreen" }

		if configuration != nil {
			return ConfigurationObservable(configuration: configuration!, db: self.db)
		} else {
			return ConfigurationObservable(configuration: Configuration(key: "isWelcomeScreen", value: "yes"), db: self.db)
		}
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

	func initialize() {
		// Save db every x time in the background
	}
	
	func save() {
		// Purge tasks on save
		let timeIntervalMonth: Double = 43800 * 60
		let timeInterval: Double = timeIntervalMonth * 6

		// Filter out tasks that are completed, and that were completed `timeInterval` ago.
		var okTasks: [Task] = []
		for task in db.tasks {
			if task.completed == false && task.dateCompleted == nil {
				okTasks.append(task)
			}
			
			if task.completed == true && task.dateCompleted != nil && task.dateCompleted!.addingTimeInterval(timeInterval) < Date() {
				okTasks.append(task)
			}
		}

		db.tasks = okTasks
		
		// Save all work to db
		AppDatabase().write(db)
	}
	
    var body: some View {
		Group {
			if isWelcomeScreenConfiguration().value == "yes" {
				ContentWelcomeView(db: db, isWelcomeScreenConfiguration: isWelcomeScreenConfiguration())
			} else {
				ContentRegularView(db: db)
			}
		}
		.onAppear {
			initialize()
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
			save()
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
			save()
		}
	}
}

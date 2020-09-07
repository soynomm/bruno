import SwiftUI

struct ContentWelcomeView: View {
	@ObservedObject var db: DatabaseObservable
	var onlyLogo: Bool = false
	
	func disableWelcomeScreen() -> Void {
		let index = db.configuration.firstIndex { $0.key == "isWelcomeScreen" }
		db.configuration[index!].value = "no"
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
				})
				.padding(.top, 20)
			}
			
		}
		.padding(20)
	}
}

struct ContentRegularView: View {
	@ObservedObject var db: DatabaseObservable
	@State var selectedView = 0
	

	/*
	func navigationBarTrailingItem() -> some View {
		return Button(action: addItem, label: {
			Image(systemName: "plus")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.font(Font.title.weight(.light))
			.frame(width: 18, height: 18)
		})
	}
	*/
	
	var body: some View {
		TasksView(db: db)
		/*
		TabView {
			TasksView(db: db, listId: currentListId)
			.tabItem {
				Image(systemName: "checkmark.circle")
				Text("Tasks")
			}.tag(0)
			
			SettingsView(purgingTasks: purgingTasksConfiguration(), purgingTasksInterval: purgingTasksIntervalConfiguration())
			.tabItem {
				Image(systemName: "gear")
				Text("Settings")
			}.tag(1)
		}
		*/
	}
}

struct ContentView: View {
	@ObservedObject var db = DatabaseObservable(database: AppDatabase().get())

	func initialize() {
		// Set up configuration for welcome screen
		let isWelcomeScreenConfiguration = db.configuration.first { $0.key == "isWelcomeScreen" }
		
		if isWelcomeScreenConfiguration == nil {
			db.configuration.append(Configuration(key: "isWelcomeScreen", value: "yes"))
		}
		
		let timer = DispatchSource.makeTimerSource()
		
		timer.schedule(deadline: .now(), repeating: .seconds(1))
		timer.setEventHandler {
			DispatchQueue.global(qos: .background).async {
			}
		}
		
		timer.resume()
		
	}
	
	func save() {
		// Purge tasks
		let purgingTasks = db.configuration.first { $0.key == "purgingTasks" }
		let purgingTasksInterval = db.configuration.first { $0.key == "purgingTasksInterval" }
		
		if purgingTasks != nil && purgingTasks!.value == "yes" && purgingTasksInterval != nil {
			let timeIntervalMonth: Double = 43800 * 60
			var timeInterval: Double
			
			if purgingTasksInterval!.value == "3months" {
				timeInterval = timeIntervalMonth * 3
			}
			
			else if purgingTasksInterval!.value == "6months" {
				timeInterval = timeIntervalMonth * 6
			}
			
			else if purgingTasksInterval!.value == "1year" {
				timeInterval = timeIntervalMonth * 12
				
			} else {
				timeInterval = timeIntervalMonth
			}
			
			db.tasks = db.tasks.filter {
				$0.completed != true && $0.dateCompleted != nil && $0.dateCompleted!.addingTimeInterval(timeInterval) > Date()
			}
		}
		
		// Save all work to db
		AppDatabase().write(db)
	}
	
	func isWelcomeScreen() -> Bool {
		let configuration = db.configuration.first(where: { $0.key == "isWelcomeScreen" })
		
		if configuration != nil && configuration!.value == "yes" {
			return true
		}
		
		if configuration != nil && configuration!.value == "no" {
			return false
		}
		
		return true
	}
	
    var body: some View {
		Group {
			if isWelcomeScreen() {
				ContentWelcomeView(db: db)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

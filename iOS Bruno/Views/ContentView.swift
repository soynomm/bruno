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
	@State var currentListId: String = ""
    @State var showLists: Bool = false
	
	func addItem(){
		db.tasks.append(Task(listId: self.currentListId))
    }
    
    func getListName(currentListId: String) -> String {
        if currentListId == "" {
            return "Inbox"
        } else {
			return db.lists.filter {
                $0.id == currentListId
            }[0].name
        }
    }
	
	func navigationBarLeadingItem() -> some View {
		return Button(action: {
			self.showLists.toggle()
		}, label: {
			Image(systemName: "tray.2")
		})
	}
	
	func navigationBarTrailingItem() -> some View {
		return Button(action: addItem, label: {
			Image(systemName: "plus")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 18, height: 18)
		})
	}
	
	var body: some View {
		NavigationView {
			TasksView(db: db, hideCompletedTasks: false, listId: currentListId)
                
            .navigationBarTitle(getListName(currentListId: self.currentListId))
			.navigationBarItems(leading: navigationBarLeadingItem(), trailing: navigationBarTrailingItem())
			.sheet(isPresented: $showLists, content: {
				ListsView(db: self.db, currentListId: self.$currentListId, showLists: self.$showLists)
			})
		}
	}
}

struct ContentView: View {
	@ObservedObject var db = DatabaseObservable(database: Kettle().get())

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
			let isWelcomeScreenConfiguration = db.configuration.first { $0.key == "isWelcomeScreen" }
			
			if isWelcomeScreenConfiguration == nil {
				db.configuration.append(Configuration(key: "isWelcomeScreen", value: "yes"))
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
			Kettle().write(db)
			print("willresign")
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
			Kettle().write(db)
			print("willterm")
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

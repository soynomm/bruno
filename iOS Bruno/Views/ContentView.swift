import SwiftUI

struct ContentWelcomeView: View {
	var onlyLogo: Bool = false
	
	func disableWelcomeScreen() -> Void {
		Kettle().updateConfiguration(Configuration(key: "welcomeScreen", value: "no"))
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
	@ObservedObject var observer: KettleObserver
	@State var currentListId: String = ""
    @State var showLists: Bool = false
	
	func addItem(){
		Kettle().addTask(Task(listId: self.currentListId))
    }
    
    func getListName(currentListId: String) -> String {
        if currentListId == "" {
            return "Inbox"
        } else {
			return observer.db.lists.filter {
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
			TasksView(observer: observer, hideCompletedTasks: ConfigurationObservable(configuration: observer.db.configuration.filter({ $0.key == "hideCompletedTasks" })[0]), listId: currentListId)
                
            .navigationBarTitle(getListName(currentListId: self.currentListId))
			.navigationBarItems(leading: navigationBarLeadingItem(), trailing: navigationBarTrailingItem())
			.sheet(isPresented: $showLists, content: {
				ListsView(observer: self.observer, currentListId: self.$currentListId, showLists: self.$showLists)
			})
		}
	}
}

struct ContentView: View {
	@ObservedObject var db = DatabaseObservable(database: Kettle().get())

    var body: some View {
		if !observer.loaded {
			ContentWelcomeView(onlyLogo: true)
		} else {
			ContentRegularView(observer: observer)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

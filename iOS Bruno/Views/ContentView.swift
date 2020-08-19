import SwiftUI

struct ContentWelcomeView: View {
	@EnvironmentObject var data: DataStore
	
	func disableWelcomeScreen() -> Void {
		data.userDB.update(UserConfigurationModel(id: "welcomeScreen", value: "no"))
	}
	
	var body: some View {
		VStack {
			Image("Logo")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 125, height: 125)
			
			Text("Hi! I'm Bruno, your best friend when it comes to getting things done.")
			.padding(40)
			.multilineTextAlignment(.center)
			
			Button(action: {
				self.disableWelcomeScreen()
			}, label: {
				Text("Let's do it!")
			})
			
		}
		.padding(20)
	}
}

struct ContentRegularView: View {
	@EnvironmentObject var data: DataStore
	@State var currentListId: String = ""
    @State var showLists: Bool = false
	
	func addItem(){
        data.taskDB.create(TaskModel(listId: self.currentListId))
    }
    
    func getListName(currentListId: String) -> String {
        if currentListId == "" {
            return "Inbox"
        } else {
            return data.lists.filter {
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
			TasksView(listId: currentListId)
                
            .navigationBarTitle(getListName(currentListId: self.currentListId))
			.navigationBarItems(leading: navigationBarLeadingItem(), trailing: navigationBarTrailingItem())
			.sheet(isPresented: $showLists, content: {
				ListsView(currentListId: self.$currentListId, showLists: self.$showLists).environmentObject(DataStore())
			})
		}
	}
}

struct ContentView: View {
	@EnvironmentObject var data: DataStore
	
	func isWelcomeScreen() -> Bool {
		let welcomeScreenConfig = data.userDB.get(id: "welcomeScreen")
		
		if welcomeScreenConfig != nil && welcomeScreenConfig?.value == "yes" {
			return true
		}
		
		if welcomeScreenConfig != nil && welcomeScreenConfig?.value == "no" {
			return false
		}
		
		data.userDB.create(UserConfigurationModel(id: "welcomeScreen", value: "yes"))
		
		return true
	}
    
    var body: some View {
		Group {
			if isWelcomeScreen() {
				ContentWelcomeView().environmentObject(DataStore())
			} else {
				ContentRegularView().environmentObject(DataStore())
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(DataStore())
    }
}

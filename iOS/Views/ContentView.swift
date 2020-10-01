import SwiftUI

struct ContentWelcomeView: View {
	@ObservedObject var isWelcomeScreenConfiguration: ConfigurationObservable
	@Environment(\.colorScheme) var colorScheme
	var onlyLogo: Bool = false
	
	// Disable the welcome screen.
	func disableWelcomeScreen() -> Void
	{
		isWelcomeScreenConfiguration.value = "no"
	}
	
	var body: some View {
		VStack {
			Image("Logo")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 50, height: 50)
			
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
	@Environment(\.colorScheme) var colorScheme
	@State var selectedView = 0

	var body: some View {
		if AppFeatures().schedule {
			TabView {
				TasksView()
				.tabItem {
					Image(systemName: "checkmark.circle")
					Text("Tasks")
				}.tag(0)

				ScheduleView()
				.tabItem {
					Image(systemName: "calendar")
					Text("Schedule")
				}.tag(1)
			}
		} else {
			TasksView()
		}
	}
}

struct ContentView: View {
	@ObservedObject var isWelcomeScreen = ConfigurationObservable(configuration: DataProvider().getConfiguration("isWelcomeScreen") ?? Configuration(key: "isWelcomeScreen", value: "yes"))

    var body: some View {
		Group {
			if isWelcomeScreen.value == "yes" {
				ContentWelcomeView(isWelcomeScreenConfiguration: isWelcomeScreen)
			} else {
				ContentRegularView()
			}
		}
	}
}

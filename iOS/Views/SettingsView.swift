import SwiftUI

struct SettingsView: View {
    @ObservedObject var purgingTasks: ConfigurationObservable
    @ObservedObject var purgingTasksInterval: ConfigurationObservable
    @State var purgingOn: Bool = false
    
    var body: some View {
        let purgeOn = Binding(
            get: { () -> Bool in
                if self.purgingTasks.value == "yes" {
                    return true
                } else {
                    return false
                }
            },
            set: {
                if $0 == true {
                    self.purgingTasks.value = "yes"
                    self.purgingOn = true
                } else {
                    self.purgingTasks.value = "no"
                    self.purgingOn = false
                }
            }
        )
        
        let purgeInterval = Binding(
            get: { () -> String in
               return self.purgingTasksInterval.value
            },
            set: {
                print($0)
                self.purgingTasksInterval.value = $0
            })
        
        NavigationView {
            Form {
                Section(header: Text("Purge completed tasks").padding(.top, 15), footer: Text("If the app is running slow, purging tasks that are completed a long time ago can speed it up.")) {
                    Toggle(isOn: purgeOn) {
                        Text("Enable purging")
                    }
                    if purgingOn {
                        Picker(selection: purgeInterval, label: Text("Purging tasks older than")) {
                            Text("1 month").tag("1month")
                            Text("3 months").tag("3months")
                            Text("6 months").tag("6months")
                            Text("1 year").tag("1year")
                        }
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .onAppear {
                if self.purgingTasks.value == "yes" {
                    self.purgingOn = true
                } else {
                    self.purgingOn = false
                }
            }
        }
    }
}

//
// Created by Asko Nomm on 09.09.2020.
//

import SwiftUI

struct ScheduleView: View {
    @State var tasks: [Task] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.tasks, id: \.self) { task in
                    Text(task.name)
                }
            }

            .navigationBarTitle("Schedule", displayMode: .inline)
        }.onAppear {
            if self.tasks.isEmpty {
                self.tasks = DataProvider().getTasks()
            }
        }
    }
}

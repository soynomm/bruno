//
// Created by Asko Nomm on 09.09.2020.
//

import SwiftUI

struct ScheduleView: View {
    @ObservedObject var db: DatabaseObservable

    var body: some View {
        NavigationView {
            Text("Hello")

            .navigationBarTitle("Schedule", displayMode: .inline)
        }
    }
}
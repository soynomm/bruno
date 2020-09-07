import SwiftUI

extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, tintColor: backgroundColor == .black ? AppConfiguration().primaryColorUIDark : AppConfiguration().primaryColorUI, textColor: backgroundColor == .black ? .white : .black))
    }
}

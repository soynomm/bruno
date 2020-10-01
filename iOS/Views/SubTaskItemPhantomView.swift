import SwiftUI

struct SubTaskItemPhantomView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: "circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(Font.title.weight(.medium))
                    .frame(width: 18, height: 18, alignment: .topLeading)
                    .opacity(0.5)
                
                Text("...")
                    .font(Font.init(UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)))
                    .opacity(0.5)
            }
            .frame(height: 30)
            .background(Color(UIColor.systemBackground))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

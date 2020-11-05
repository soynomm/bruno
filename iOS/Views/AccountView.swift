//
// Created by Asko Nomm on 09.09.2020.
//

import SwiftUI

struct AccountView: View {

    var body: some View {
        NavigationView {
            VStack {
                Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 65, height: 65)
                .cornerRadius(20)
                
            Text("Back up your tasks with an account.")
                .padding(20)
                .multilineTextAlignment(.center)
                
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .opacity(0.5)
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                    
                    HStack {
                        Rectangle()
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 20, height: 30)
                            .offset(x: 7)
                        
                        Text("Log In or Sign Up")
                            .font(Font.init(UIFont.systemFont(ofSize: 12, weight: .semibold)))
                            .textCase(.uppercase)
                            .background(Color(UIColor.systemBackground))
                        
                        Rectangle()
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 20, height: 30)
                            .offset(x: -7)
                    }
                }
            }
            .padding(20)

            .navigationBarTitle("Account", displayMode: .inline)
        }
    }
}

//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI

struct AccountView: View {

    @State private var errorMsg: String? = nil
    @State private var isLoading = true
    @ObservedObject var userObj: AuthService
    
    var body: some View {
        VStack {
            Text("Account Username: \(userObj.currentUser?.username ?? "Username Not Found")")
            
            NavigationLink(destination: WelcomeView()){
                Text("Log Out")
            }.padding()
        }
        .padding()
    }
}

#Preview {
    AccountView(userObj: AuthService())
}

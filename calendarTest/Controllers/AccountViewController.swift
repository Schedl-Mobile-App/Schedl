//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI

struct AccountViewController: View {

    @State private var errorMsg: String? = nil
    @State private var isLoading = true
    @ObservedObject var viewModel: AuthService
    
    var body: some View {
        VStack {
            Text("Account Username: \(viewModel.currentUser?.username ?? "Username Not Found")")
            
            NavigationLink(destination: WelcomeViewController()){
                Text("Log Out")
            }.padding()
        }
        .padding()
    }
}

#Preview {
    AccountViewController(viewModel: AuthService())
}

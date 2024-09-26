//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI

struct AccountViewController: View {
    
    @State private var userData: User? = nil
    @State private var errorMsg: String? = nil
    @State private var isLoading = true
    
    var body: some View {
        VStack {
                    if isLoading {
                        Text("Loading...")
                            .onAppear {
                                FirebaseManager.shared.fetchUser {
                                    user, error in
                                    DispatchQueue.main.async {
                                        if let user = user {
                                            self.userData = user
                                        } else if let error = error {
                                                self.errorMsg = error.localizedDescription
                                        }
                                        self.isLoading = false
                                    }
                                }
                            }
                    } else {
                        // Display your data here
                        if errorMsg != nil {
                            Text(errorMsg ?? "No error message")
                        }
                        else {
                            Text("Account Username: \(userData?.username ?? "Username not Found")")
                        }
                    }
                }
                .padding()
    }
}

#Preview {
    AccountViewController()
}

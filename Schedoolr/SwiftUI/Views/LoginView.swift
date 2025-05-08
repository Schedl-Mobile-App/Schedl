//
//  LoginViewController.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                Text("Schedulr")
                    .font(.largeTitle)
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)

                Text("Sign in to continue")
                    .font(.system(size: 20, design: .monospaced))

                Group {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .foregroundStyle(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .overlay {
                            TextField("Email", text: $authViewModel.email)
                                .padding(.horizontal)
                        }
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .foregroundStyle(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .overlay {
                            TextField("Password", text: $authViewModel.password)
                                .padding(.horizontal)
                        }
                }
                .padding(.horizontal)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 4)
                }

                Button(action: {
                    Task {
                        try await authViewModel.login()
                    }
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .overlay {
                            Text("Login")
                                .foregroundColor(Color.white)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .tracking(2)
                        }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .foregroundStyle(Color("FormButtons"))
            }
            .padding(.horizontal)
            .navigationDestination(isPresented: $authViewModel.isLoggedIn) {
                MainTabBarView()
                    .environmentObject(authViewModel)
            }
            Spacer()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

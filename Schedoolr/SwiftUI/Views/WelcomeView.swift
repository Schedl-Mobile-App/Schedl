//
//  WelcomeViewController.swift
//  calendarTest
//
//  Created by David Medina on 10/4/24.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authService: AuthService
    @State var shouldNavigate: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            VStack(alignment: .center, spacing: 20) {
                Text("Schedulr")
                    .font(.largeTitle)
                    .fontDesign(.monospaced)
                    .fontWeight(.bold)
                
                Text("Create an Account")
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
                            TextField("Username", text: $authService.username)
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
                            TextField("Email", text: $authService.email)
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
                            TextField("Password", text: $authService.password)
                                .padding(.horizontal)
                        }
                }
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .tracking(1)
                .padding(.horizontal)
                
                Button(action: {
                    Task {
                        try await authService.signUp()
                    }
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .overlay {
                            Text("Sign Up")
                                .foregroundColor(Color.white)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .tracking(2)
                        }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .foregroundStyle(Color("FormButtons"))
                
                HStack {
                    Text("Already have an account?")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .tracking(2)
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .foregroundStyle(.primary)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .tracking(1)
                            .underline()
                    }
                }
            }
            .navigationDestination(isPresented: $authService.isLoggedIn) {
                MainTabBarView()
                    .environmentObject(authService)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthService())
}

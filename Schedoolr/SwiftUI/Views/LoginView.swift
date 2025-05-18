//
//  LoginViewController.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @FocusState var isFocused: AccountInfoFields?

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 200)
                    VStack(alignment: .center, spacing: 10) {
                        Text("Schedl")
                            .font(.system(size: 36, weight: .heavy, design: .monospaced))
                        
                        Text("Sign in to continue")
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                    }
                        
                        Group {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .foregroundStyle(.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .overlay {
                                    TextField("Email", text: $authViewModel.email)
                                        .padding(.horizontal)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                                        .focused($isFocused, equals: .email)
                                }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .foregroundStyle(.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .overlay {
                                    TextField("Password", text: $authViewModel.password)
                                        .padding(.horizontal)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                                        .focused($isFocused, equals: .password)
                                }
                        }
                        
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
                            Text("Login")
                                .foregroundColor(Color(hex: 0xf7f4f2))
                                .font(.system(size: 18, weight: .medium, design: .monospaced))
                                .tracking(1.5)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color(hex: 0x47a2be))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 25)
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                isFocused = nil
            }
            .onChange(of: isFocused, {
                authViewModel.errorMessage = nil
            })
        }
        .navigationDestination(isPresented: $authViewModel.isLoggedIn) {
            MainTabBarView()
                .environmentObject(authViewModel)
        }
        .navigationBarBackButtonHidden(true)

    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

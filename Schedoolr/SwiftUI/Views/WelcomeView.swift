//
//  WelcomeViewController.swift
//  calendarTest
//
//  Created by David Medina on 10/4/24.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var shouldNavigate: Bool = false
    @FocusState var isFocused: AccountInfoFields?

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            ScrollView() {
                VStack(spacing: 20) {
                    Spacer(minLength: 150)
                    VStack(alignment: .center, spacing: 10) {
                        Text("Schedl")
                            .font(.system(size: 36, weight: .heavy, design: .monospaced))
                        Text("Create an Account")
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                    }
                    
                    Group {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(.clear)
                            .overlay {
                                TextField("Username", text: $authViewModel.username)
                                    .padding(.horizontal)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                                    .foregroundStyle(Color(hex: 0x666666))
                                    .focused($isFocused, equals: .username)
                            }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(.clear)
                            .overlay {
                                TextField("Display Name", text: $authViewModel.displayName)
                                    .padding(.horizontal)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                                    .foregroundStyle(Color(hex: 0x666666))
                                    .focused($isFocused, equals: .displayName)
                            }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(.clear)
                            .overlay {
                                TextField("Email", text: $authViewModel.email)
                                    .padding(.horizontal)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                                    .foregroundStyle(Color(hex: 0x666666))
                                    .focused($isFocused, equals: .email)
                            }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(.clear)
                            .overlay {
                                TextField("Password", text: $authViewModel.password)
                                    .padding(.horizontal)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                                    .foregroundStyle(Color(hex: 0x666666))
                                    .focused($isFocused, equals: .password)
                            }
                    }
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .tracking(1)
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 4)
                    }
                    
                    Button(action: {
                        Task {
                            try await authViewModel.signUp()
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(Color(hex: 0xf7f4f2))
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .tracking(1.5)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hex: 0x47a2be))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .tracking(1.25)
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .tracking(1.25)
                                .underline()
                                .foregroundStyle(Color(hex: 0x47a2be))
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
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
    WelcomeView()
        .environmentObject(AuthViewModel())
}

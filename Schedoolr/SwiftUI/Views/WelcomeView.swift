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
    @State var keyboardOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            ScrollView() {
                VStack(spacing: 15) {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Schedl")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Create an Account")
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(0.1)
                    }
                    
                    VStack(spacing: 20) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    TextField("Username", text: $authViewModel.username)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .username)
                                        .autocorrectionDisabled(true)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }

                            HStack {
                                Spacer(minLength: 8)
                                Text("Username")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .username || !authViewModel.username.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    TextField("Display Name", text: $authViewModel.displayName)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .displayName)
                                        .autocorrectionDisabled(true)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }

                            HStack {
                                Spacer(minLength: 8)
                                Text("Display Name")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .displayName || !authViewModel.displayName.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    TextField("Email", text: $authViewModel.email)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .email)
                                        .autocorrectionDisabled(true)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Email")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .email || !authViewModel.email.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    SecureField("Password", text: $authViewModel.password)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .password)
                                        .autocorrectionDisabled(true)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                }

                            HStack {
                                Spacer(minLength: 8)
                                Text("Password")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .password || !authViewModel.password.isEmpty ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                        }                    }
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
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hex: 0x47a2be))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(0.1)
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .font(.system(size: 17, weight: .medium, design: .monospaced))
                                .tracking(0.1)
                                .underline()
                                .foregroundStyle(Color(hex: 0x47a2be))
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
            .defaultScrollAnchor(.center)
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                isFocused = nil
            }
            .onChange(of: isFocused, {
                authViewModel.errorMessage = nil
            })
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel(hasOnboarded: true))
}

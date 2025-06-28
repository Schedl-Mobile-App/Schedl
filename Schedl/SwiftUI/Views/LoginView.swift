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
    @State var keyboardHeight: CGFloat = 0
    
    @State var hasTriedSubmitting: Bool = false
    
    @State var email: String? = nil
    @State var password: String? = nil
    
    var emailBinding: Binding<String> {
        Binding(
            get: { email ?? "" },
            set: { newValue in
                email = newValue.isEmpty ? nil : newValue
            }
        )
    }
    var passwordBinding: Binding<String> {
        Binding(
            get: { password ?? "" },
            set: { newValue in
                password = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    @State var emailError = ""
    @State var passwordError = ""

    var body: some View {
        ZStack(alignment: .center) {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 15) {
                    Spacer()
                    VStack(alignment: .center, spacing: 8) {
                        Text("Schedl")
                            .font(.custom("GillSans-Bold", size: 36))
                            .foregroundStyle(Color(hex: 0x333333))
                        
                        Text("Sign in to Continue")
                            .font(.headline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(-0.25)
                    }
                        
                    VStack(spacing: 15) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    TextField("Email", text: emailBinding)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .email)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && email == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Email")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .fontDesign(.monospaced)
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .email || email != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(emailError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !emailError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        .padding(.bottom, emailError.isEmpty ? 0 : 10)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    SecureField("Password", text: passwordBinding)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .password)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && password == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .fontDesign(.monospaced)
                                Spacer(minLength: 8)
                            }
                            .background(
                                Rectangle()
                                    .fill(Color(hex: 0xf7f4f2))
                                    .frame(height: 12)
                            )
                            .fixedSize()
                            .offset(x: 12, y: -7)
                            .opacity(isFocused == .password || password != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(passwordError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !passwordError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        .padding(.bottom, passwordError.isEmpty ? 0 : 10)
                    }
                    .padding(.bottom, passwordError.isEmpty ? 0 : 4)
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(Color(hex: 0xE84D3D))
                            .font(.footnote)
                            .padding(.top, 2)
                    }
                    
                    Button(action: {
                        
                        var isValid = true
                        if email == nil {
                            emailError = "Email is required"
                            isValid = false
                        }
                        if password == nil {
                            passwordError = "Password is required"
                            isValid = false
                        }
                                                
                        if !isValid {
                            hasTriedSubmitting = true
                            return
                        }
                        
                        let validEmail = email!
                        let validPassword = password!
                        
                        Task {
                            await authViewModel.login(email: validEmail, password: validPassword)
                        }
                    }) {
                        Text("Login")
                            .foregroundColor(Color(hex: 0xf7f4f2))
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color(hex: 0x47a2be))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    HStack {
                        Text("Don't have an account?")
                            .font(.headline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(-0.25)
                        NavigationLink(destination: WelcomeView()) {
                            Text("Sign Up")
                                .font(.headline)
                                .fontWeight(.medium)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .underline()
                                .foregroundStyle(Color(hex: 0x47a2be))
                        }
                    }
                    
                    Spacer()
                }
                .frame(height: UIScreen.main.bounds.height, alignment: .center)
                .padding(.horizontal, 25)
                .keyboardHeight($keyboardHeight)
                .animation(.easeIn(duration: 0.16), value: keyboardHeight)
                .offset(y: -keyboardHeight / 2)
                .onChange(of: isFocused) {
                    hasTriedSubmitting = false
                    emailError = ""
                    passwordError = ""
                }
            }
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
    LoginView()
        .environmentObject(AuthViewModel(hasOnboarded: true))
}

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
    @State var keyboardHeight: CGFloat = 0
    @State var hasTriedSubmitting: Bool = false
    
    @State var email: String? = nil
    @State var password: String? = nil
    @State var displayName: String? = nil
    @State var username: String? = nil
    
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
    var displayNameBinding: Binding<String> {
        Binding(
            get: { displayName ?? "" },
            set: { newValue in
                displayName = newValue.isEmpty ? nil : newValue
            }
        )
    }
    var usernameBinding: Binding<String> {
        Binding(
            get: { username ?? "" },
            set: { newValue in
                username = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    @State var emailError = ""
    @State var passwordError = ""
    @State var displayNameError = ""
    @State var usernameError = ""

    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 15) {
                    Spacer()
                    VStack(alignment: .center, spacing: 8) {
                        Text("Schedl")
                            .font(.custom("GillSans-Bold", size: 36))
                            .foregroundStyle(Color(hex: 0x333333))
                        Text("Create an Account")
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
                                    TextField("Username", text: usernameBinding)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .username)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && username == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Username")
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
                            .opacity(isFocused == .username || username != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(usernameError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !usernameError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        .padding(.bottom, usernameError.isEmpty ? 0 : 14)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .foregroundStyle(.clear)
                                .overlay {
                                    TextField("Display Name", text: displayNameBinding)
                                        .padding(.horizontal, 20)
                                        .textFieldStyle(.plain)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .fontDesign(.monospaced)
                                        .foregroundStyle(Color(hex: 0x333333))
                                        .tracking(0.1)
                                        .focused($isFocused, equals: .displayName)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hasTriedSubmitting && displayName == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
                                }
                            
                            HStack {
                                Spacer(minLength: 8)
                                Text("Display Name")
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
                            .opacity(isFocused == .displayName || displayName != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isFocused)
                            
                            Text(displayNameError)
                                .font(.footnote)
                                .offset(x: 12, y: 53)
                                .foregroundStyle(.red)
                                .opacity(hasTriedSubmitting && !displayNameError.isEmpty ? 1 : 0)
                                .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
                        }
                        .padding(.bottom, displayNameError.isEmpty ? 0 : 14)
                        
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
                        .padding(.bottom, emailError.isEmpty ? 0 : 14)
                        
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
                                        .stroke(hasTriedSubmitting && !passwordError.isEmpty ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
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
                        .padding(.bottom, passwordError.count > 50 ? 15 : 0)
                    }
                    .padding(.bottom, !passwordError.isEmpty ? 14 : 0)
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(Color(hex: 0xE84D3D))
                            .font(.footnote)
                            .padding(.top, 2)
                    }
                    
                    Button(action: {
                        
                        usernameError = ""
                        displayNameError = ""
                        emailError = ""
                        passwordError = ""
                        
                        var isValid = true
                        if username == nil {
                            usernameError = "Username is required"
                            isValid = false
                        }
                        if displayName == nil {
                            displayNameError = "Display name is required"
                            isValid = false
                        }
                        if email == nil {
                            emailError = "Email is required"
                            isValid = false
                        }
                        if password == nil {
                            passwordError = "Password is required"
                            isValid = false
                        } else {
                            let result = authViewModel.isValidPassword(password!)
                            if result != nil {
                                passwordError = result!
                                isValid = false
                            }
                        }
                        
                        if !isValid {
                            hasTriedSubmitting = true
                            return
                        }
                        
                        let validUsername = username!
                        let validDisplayName = displayName!
                        let validEmail = email!
                        let validPassword = password!
                        
                        Task {
                            await authViewModel.signUp(username: validUsername, displayName: validDisplayName, email: validEmail, password: validPassword)
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(Color(hex: 0xf7f4f2))
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color(hex: 0x47a2be))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    HStack {
                        Text("Already have an account?")
                            .font(.headline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .foregroundStyle(Color(hex: 0x666666))
                            .tracking(-0.25)
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
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
                    usernameError = ""
                    displayNameError = ""
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
    WelcomeView()
        .environmentObject(AuthViewModel(hasOnboarded: true))
}

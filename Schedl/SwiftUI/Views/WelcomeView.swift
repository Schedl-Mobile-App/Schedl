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
    
    @State var emailError = ""
    @State var passwordError = ""
    @State var displayNameError = ""
    @State var usernameError = ""

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            ScrollView(.vertical) {
                Spacer(minLength: (UIScreen.current?.bounds.height ?? 0) * 0.175)
                VStack {
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
                    
                    DisplayNameField(displayName: $displayName, displayNameError: $displayNameError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    UsernameField(username: $username, usernameError: $usernameError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    EmailField(email: $email, emailError: $emailError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    PasswordField(password: $password, passwordError: $passwordError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    .padding(.bottom, passwordError.isEmpty ? 0 : 4)
                    
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
                    }, label: {
                        Text("Sign Up")
                            .foregroundColor(Color(hex: 0xf7f4f2))
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: 0x3C859E))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.vertical, 4)
                    
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
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 25)
                .keyboardHeight($keyboardHeight)
                .animation(.easeIn(duration: 0.16), value: keyboardHeight)
                .offset(y: -keyboardHeight / 2)
            }
            .onChange(of: isFocused) {
                hasTriedSubmitting = false
                usernameError = ""
                displayNameError = ""
                emailError = ""
                passwordError = ""
                authViewModel.errorMessage = nil
            }
            .onTapGesture {
                isFocused = nil
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isFocused = nil
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct UsernameField: View {
    
    @Binding var username: String?
    @Binding var usernameError: String
    @Binding var hasTriedSubmitting: Bool
    var isFocused: FocusState<AccountInfoFields?>.Binding
    
    var usernameBinding: Binding<String> {
        Binding(
            get: { username ?? "" },
            set: { newValue in
                username = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 0) {
            
                TextField("Username", text: usernameBinding)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(0.1)
                    .focused(isFocused, equals: .username)
                    .autocorrectionDisabled(true)
                
                Spacer()
                Button(action: {
                    username = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .hidden(username == nil)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && username == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 4)
                    Text("Username")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -10)
                .opacity(isFocused.wrappedValue == .username || username != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
                
                Text(usernameError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !usernameError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 6)
        .padding(.bottom, hasTriedSubmitting && !usernameError.isEmpty ? 8 : 0)
    }
}

struct DisplayNameField: View {
    
    @Binding var displayName: String?
    @Binding var displayNameError: String
    @Binding var hasTriedSubmitting: Bool
    var isFocused: FocusState<AccountInfoFields?>.Binding
    
    var displayNameBinding: Binding<String> {
        Binding(
            get: { displayName ?? "" },
            set: { newValue in
                displayName = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 0) {
            
                TextField("First and Last Name", text: displayNameBinding)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(0.1)
                    .focused(isFocused, equals: .displayName)
                    .autocorrectionDisabled(true)
                
                Spacer()
                Button(action: {
                    displayName = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .hidden(displayName == nil)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && displayName == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 4)
                    Text("Display Name")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -10)
                .opacity(isFocused.wrappedValue == .displayName || displayName != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
                
                Text(displayNameError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !displayNameError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 6)
        .padding(.bottom, hasTriedSubmitting && !displayNameError.isEmpty ? 8 : 0)
    }
}

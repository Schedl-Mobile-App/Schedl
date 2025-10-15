//
//  WelcomeViewController.swift
//  calendarTest
//
//  Created by David Medina on 10/4/24.
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject private var authVM: AuthViewModel
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
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 10) {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    Text("Schedl")
                        .font(.custom("GillSans-Bold", size: 36))
                        .foregroundStyle(Color("PrimaryText"))
                    
                    Text("Create an Account")
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color("SecondaryText"))
                        .tracking(-0.25)
                }
                
                VStack(spacing: 0) {
                    DisplayNameField(displayName: $displayName, displayNameError: $displayNameError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    UsernameField(username: $username, usernameError: $usernameError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    EmailField(email: $email, emailError: $emailError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    PasswordField(password: $password, passwordError: $passwordError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                }
            
//                if let error = authViewModel.errorMessage {
//                    Text(error)
//                        .foregroundStyle(Color(hex: 0xE84D3D))
//                        .font(.footnote)
//                        .padding(.vertical, 2)
//                }
                
                Button(action: {
                    withAnimation {
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
                            let result = authVM.isValidPassword(password!)
                            if result != nil {
                                passwordError = result!
                                isValid = false
                            }
                        }
                        
                        if !isValid {
                            hasTriedSubmitting = true
                            return
                        }
                    }
                    
                    guard let username = username, let displayName = displayName, let email = email, let password = password else { return }
                    
                    Task {
                        await authVM.signUp(username: username, displayName: displayName, email: email, password: password)
                    }
                }, label: {
                    Text("Sign Up")
                        .foregroundColor(Color.white)
                        .font(.headline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("ButtonColors"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
                
                HStack {
                    Text("Already have an account?")
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color("PrimaryText"))
                        .tracking(-0.25)
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .font(.headline)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .underline()
                            .foregroundStyle(Color("SecondaryText"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            .padding(.horizontal, 25)
            .frame(maxHeight: .infinity)
            .onChange(of: isFocused) {
                withAnimation {
                    hasTriedSubmitting = false
                    usernameError = ""
                    displayNameError = ""
                    emailError = ""
                    passwordError = ""
                    authVM.errorMessage = nil
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Spacer()
                Button("Done", action: {
                    isFocused = nil
                })
            }
        }
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
    
    private var isLabelFloating: Bool {
        isFocused.wrappedValue == .username || username != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                
                TextField("", text: usernameBinding, prompt:
                            Text("Username")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color("SecondaryText"))
                                .tracking(-0.25))
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("PrimaryText"))
                    .tracking(-0.25)
                    .focused(isFocused, equals: .username)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)
                
                Spacer()
                Button(action: {
                    withAnimation {
                        username = nil
                    }
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color("IconColors"))
                }
                .opacity(username == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: username)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && username == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Username")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor")) // This background cuts the border
                        .offset(y: -8) // Move label up or keep it centered
                        .padding(.leading, 16)
                }
                .opacity(isLabelFloating ? 1 : 0) // Show label only when floating
                .animation(.easeInOut(duration: 0.2), value: isLabelFloating)
            }
            
            Text(usernameError.isEmpty ? " " : usernameError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(usernameError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: usernameError.isEmpty)
        }
        .padding(.top, 8)
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
    
    private var isLabelFloating: Bool {
        isFocused.wrappedValue == .displayName || displayName != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
            
                TextField("", text: displayNameBinding, prompt:
                            Text("First and Last Name")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color("SecondaryText"))
                                .tracking(-0.25))
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("PrimaryText"))
                    .tracking(-0.25)
                    .focused(isFocused, equals: .displayName)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
                    .textContentType(.name)
                
                Spacer()
                Button(action: {
                    withAnimation {
                        displayName = nil
                    }
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color("IconColors"))
                }
                .opacity(displayName == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: displayName)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && displayName == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Display Name")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor")) // This background cuts the border
                        .offset(y: -9) // Move label up or keep it centered
                        .padding(.leading, 16)
                }
                .opacity(isLabelFloating ? 1 : 0) // Show label only when floating
                .animation(.easeInOut(duration: 0.2), value: isLabelFloating)
            }
            
            Text(displayNameError.isEmpty ? " " : displayNameError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(displayNameError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: displayNameError.isEmpty)
        }
        .padding(.top, 8)
    }
}

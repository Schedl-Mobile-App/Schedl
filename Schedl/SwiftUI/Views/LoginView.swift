//
//  LoginViewController.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var authVM: AuthViewModel
    @FocusState var isFocused: AccountInfoFields?
    @State var keyboardHeight: CGFloat = 0
    @Environment(\.dismiss) var dismiss
    
    @State var hasTriedSubmitting: Bool = false
    
    @State var email: String? = nil
    @State var password: String? = nil
    
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
        ZStack(alignment: .topLeading) {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 10) {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    Text("Schedl")
                        .font(.custom("GillSans-Bold", size: 36))
                        .foregroundStyle(Color("PrimaryText"))
                    
                    Text("Sign in to Continue")
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color("PrimaryText"))
                        .tracking(-0.25)
                }
                
                VStack(spacing: 0) {
                    EmailField(email: $email, emailError: $emailError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                    PasswordField(password: $password, passwordError: $passwordError, hasTriedSubmitting: $hasTriedSubmitting, isFocused: $isFocused)
                }
                
                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundStyle(Color("ErrorTextColor"))
                        .font(.footnote)
                }
                
                Button(action: {
                    withAnimation {
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
                    }
                    
                    guard let email = email, let password = password else { return }
                    
                    Task {
                        await authVM.login(email: email, password: password)
                    }
                }, label: {
                    Text("Login")
                        .foregroundColor(Color.white)
                        .font(.headline)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                })
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("ButtonColors"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical, 4)
                
                HStack {
                    Text("Don't have an account?")
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color("PrimaryText"))
                        .tracking(-0.25)
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Sign Up")
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
            .simultaneousGesture(TapGesture().onEnded{
                withAnimation {
                    hasTriedSubmitting = false
                    emailError = ""
                    passwordError = ""
                    authVM.errorMessage = nil
                }
            })
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

#Preview {
    LoginView()
}

struct EmailField: View {
    
    @Binding var email: String?
    @Binding var emailError: String
    @Binding var hasTriedSubmitting: Bool
    var isFocused: FocusState<AccountInfoFields?>.Binding
    
    var emailBinding: Binding<String> {
        Binding(
            get: { email ?? "" },
            set: { newValue in
                email = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    private var isLabelFloating: Bool {
        isFocused.wrappedValue == .email || email != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
            
                TextField("", text: emailBinding, prompt:
                            Text("Email")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color("SecondaryText"))
                                .tracking(-0.25))
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("PrimaryText"))
                    .tracking(-0.25)
                    .focused(isFocused, equals: .email)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                
                Spacer()
                Button(action: {
                    withAnimation {
                        email = nil
                    }
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color("IconColors"))
                }
                .opacity(email == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: email)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && email == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Email")
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

            Text(emailError.isEmpty ? " " : emailError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(emailError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: emailError.isEmpty)
        }
        .padding(.top, 8)
    }
}

struct PasswordField: View {
    
    @Binding var password: String?
    @Binding var passwordError: String
    @Binding var hasTriedSubmitting: Bool
    var isFocused: FocusState<AccountInfoFields?>.Binding
    
    var passwordBinding: Binding<String> {
        Binding(
            get: { password ?? "" },
            set: { newValue in
                password = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    private var isLabelFloating: Bool {
        isFocused.wrappedValue == .password || password != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
            
                SecureField("", text: passwordBinding, prompt:
                                Text("Password")
                                    .font(.subheadline)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(Color("SecondaryText"))
                                    .tracking(-0.25))
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("PrimaryText"))
                    .tracking(-0.25)
                    .focused(isFocused, equals: .password)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(.password)
                
                Spacer()
                Button(action: {
                    password = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color("IconColors"))
                }
                .opacity(password == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: password)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && password == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                // This HStack creates the label with padding for the background.
                HStack(spacing: 0) {
                    Text("Password")
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

            Text(passwordError.isEmpty ? " " : passwordError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(passwordError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: passwordError.isEmpty)
        }
        .padding(.top, 8)
    }
}

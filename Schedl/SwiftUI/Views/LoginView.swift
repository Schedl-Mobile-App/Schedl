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
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            ScrollView(.vertical) {
                Spacer(minLength: (UIScreen.current?.bounds.height ?? 0) * 0.3)
                VStack {
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
                    }, label: {
                        Text("Login")
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
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 25)
                .keyboardHeight($keyboardHeight)
                .animation(.easeIn(duration: 0.16), value: keyboardHeight)
                .offset(y: -keyboardHeight / 2)
            }
            .onChange(of: isFocused) {
                hasTriedSubmitting = false
                emailError = ""
                passwordError = ""
            }
            .onTapGesture {
                isFocused = nil
            }
            .onChange(of: isFocused, {
                authViewModel.errorMessage = nil
            })
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

#Preview {
    LoginView()
        .environmentObject(AuthViewModel(hasOnboarded: true))
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
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 0) {
            
                TextField("Email", text: emailBinding)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(0.1)
                    .focused(isFocused, equals: .email)
                    .autocorrectionDisabled(true)
                
                Spacer()
                Button(action: {
                    email = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .hidden(email == nil)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && email == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 4)
                    Text("Email")
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
                .opacity(isFocused.wrappedValue == .email || email != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
                
                Text(emailError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !emailError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 6)
        .padding(.bottom, hasTriedSubmitting && !emailError.isEmpty ? 8 : 0)
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
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 0) {
            
                TextField("Password", text: passwordBinding)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(0.1)
                    .focused(isFocused, equals: .password)
                    .autocorrectionDisabled(true)
                
                Spacer()
                Button(action: {
                    password = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .hidden(password == nil)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && password == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 4)
                    Text("Password")
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
                .opacity(isFocused.wrappedValue == .password || password != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
                
                Text(passwordError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !passwordError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 6)
        .padding(.bottom, hasTriedSubmitting && !passwordError.isEmpty ? 8 : 0)
    }
}

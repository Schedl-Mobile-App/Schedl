//
//  SignUpViewController.swift
//  calendarTest
//
//  Created by David Medina on 10/4/24.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var userObj = AuthService()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Create an Account")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Username", text: $userObj.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Email", text: $userObj.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $userObj.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let error = userObj.errorMsg {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {userObj.signUp(username: userObj.username, email: userObj.email, password: userObj.password)}) {
                    Text("Register")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .navigationDestination(isPresented: $userObj.isLoggedIn){
                MainTabBarView(userObj: userObj)                    
            }
        }
    }
}

#Preview {
    SignUpView()
}

//
//  SignUpViewController.swift
//  calendarTest
//
//  Created by David Medina on 10/4/24.
//

import SwiftUI

struct SignUpViewController: View {
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var viewModel = AuthService()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Create an Account")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let error = viewModel.errorMsg {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {viewModel.signUp(username: viewModel.username, email: viewModel.email, password: viewModel.password)}) {
                    Text("Register")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .navigationDestination(isPresented: $viewModel.isLoggedIn){
                MainTabBarViewController(viewModel: viewModel)
                    .environmentObject(dateHolder)
                    
            }
        }
    }
}

#Preview {
    SignUpViewController()
        .environmentObject(DateHolder())
}

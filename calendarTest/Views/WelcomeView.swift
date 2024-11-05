//
//  WelcomeViewController.swift
//  calendarTest
//
//  Created by David Medina on 10/4/24.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var dateHolder: DateHolder
    @ObservedObject var viewModel = AuthService()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: SignUpView()){
                    
                    Text("Make an Account")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }.padding()
                
                NavigationLink(destination: LoginView()){
                    
                    Text("Already have an Account?")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }.padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(DateHolder())
}

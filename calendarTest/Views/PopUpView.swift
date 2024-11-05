//
//  PopUpView.swift
//  calendarTest
//
//  Created by David Medina on 10/7/24.
//

import SwiftUI

struct PopUpView: View {
    
    @State private var title: String = ""
    @State private var username: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Name TextField
                Section(header: Text("Name")) {
                    TextField("Enter the title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }

                // Email TextField
                Section(header: Text("Email")) {
                    TextField("Enter your username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                // Submit Button
                Section {
                    Button(action: {
                        print("successfull")
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Input Form")
        }
        .frame(width: 300, height: 200)
        .background()
        .cornerRadius(10)
        .shadow(radius: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .transition(.scale)
        .zIndex(1)
    }
}

#Preview {
    PopUpView()
}

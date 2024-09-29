//
//  UserSession.swift
//  calendarTest
//
//  Created by David Medina on 9/27/24.
//

import Combine

class UserSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
    var currentUser: User?
    
    func logIn(user: User) {
        self.currentUser = user
        self.isLoggedIn = true
    }
    
    func logOut() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
}

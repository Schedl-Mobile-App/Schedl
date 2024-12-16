//
//  Auth.swift
//  calendarTest
//
//  Created by David Medina on 9/26/24.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation

class AuthService: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var currentUser: User?
    @Published var errorMsg: String?
    @Published var isLoggedIn: Bool = false
    private var userListener: DatabaseHandle?

    @MainActor
    func login(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let userId = authResult.user.uid
            
            let fetchedUser = try await FirebaseManager.shared.fetchUserAsync(id: userId)
            setupUserListener(userId: userId)
            self.currentUser = fetchedUser
            self.isLoggedIn = true
        } catch {
            self.errorMsg = "Failed to login: \(error.localizedDescription)"
            self.password = ""
        }
    }
    
    @MainActor
    func signUp(username: String, email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let userId = authResult.user.uid
            
            var userObj = User(
                id: userId,
                username: username,
                email: email,
                schedules: [],
                profileImage: "",
                requestIds: [],
                friendIds: [],
                creationDate: Date().timeIntervalSince1970
            )
            
            let defaultSchedule = Schedule.defaultSchedule(userId: userId, username: username)
            let scheduleId: String = try await FirebaseManager.shared.createNewScheduleAsync(scheduleData: defaultSchedule, userId: userId)
            userObj.schedules.append(scheduleId)
            try await FirebaseManager.shared.saveNewUserAsync(userData: userObj)
            try await login(email: email, password: password)
            
        } catch {
            throw AuthError.signUpError
        }
    }

    @MainActor
    func logout() async throws {
        do {
            self.removeUserListener()
            try Auth.auth().signOut()
            currentUser = nil
            isLoggedIn = false
        } catch {
            throw AuthError.logoutError
        }
    }
    
    @MainActor
    func setupUserListener(userId: String) {
        removeUserListener()
        userListener = FirebaseManager.shared.observeUserChanges(id: userId) { [weak self] user in
            self?.currentUser = user
        }
    }
    
    @MainActor
    func removeUserListener() {
        if let handle = userListener {
            FirebaseManager.shared.removeUserObserver(handle: handle)
            userListener = nil
        }
    }
}

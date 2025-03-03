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

    func resetInfo() {
        self.username = ""
        self.email = ""
        self.password = ""
    }
    
    @MainActor
    func login() async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let userId = authResult.user.uid
            
            let fetchedUser = try await FirebaseManager.shared.fetchUserAsync(id: userId)
            setupUserListener(userId: userId)
            self.currentUser = fetchedUser
            self.isLoggedIn = true
            resetInfo()
            
        } catch {
            self.errorMsg = "Failed to login: \(error.localizedDescription)"
            resetInfo()
        }
    }
    
    @MainActor
    func signUp() async throws {
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
            self.currentUser = userObj
            self.isLoggedIn = true
            resetInfo()
            
        } catch {
            throw AuthError.signUpError
        }
    }

    @MainActor
    func logout() async throws {
        do {
            self.removeUserListener(userId: self.currentUser?.id ?? "")
            try Auth.auth().signOut()
            currentUser = nil
            isLoggedIn = false
        } catch {
            throw AuthError.logoutError
        }
    }
    
    @MainActor
    func setupUserListener(userId: String) {
        removeUserListener(userId: userId)
        userListener = FirebaseManager.shared.observeUserChanges(id: userId) { [weak self] user in
            self?.currentUser = user
        }
    }
    
    @MainActor
    func removeUserListener(userId: String) {
        if let handle = userListener {
            FirebaseManager.shared.removeUserObserver(handle: handle, userId: userId)
            userListener = nil
        }
    }
}

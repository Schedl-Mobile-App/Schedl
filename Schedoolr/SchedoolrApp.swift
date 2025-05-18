//
//  calendarTestApp.swift
//  calendarTest
//
//  Created by Salvador Pruneda on 9/2/24.
//

import SwiftUI
import FirebaseAppCheck
import FirebaseAuth
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
    #if DEBUG
    // Add this before Firebase.configure()
    let providerFactory = AppCheckDebugProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)
    #endif
      
    
      
    FirebaseApp.configure()
    return true
  }
}

@main
struct SchedoolrApp: App {
    
    init() {
        UserDefaults.standard.reset()
    }
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // define an instance of our AuthViewModel to gain access to our log in functions
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if UserDefaults.standard.hasOnboarded {
                    WelcomeView()
                } else {
                    OnboardingViewOne()
                }
            }
            .environmentObject(authViewModel)
        }
    }
}

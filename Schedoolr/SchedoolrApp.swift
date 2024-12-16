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
      
//    #if DEBUG
//    // Add this before Firebase.configure()
//    let providerFactory = AppCheckDebugProviderFactory()
//    AppCheck.setAppCheckProviderFactory(providerFactory)
//    #endif
      
    #if DEBUG
    let providerFactory = DebugAppCheckProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)
    #endif
      
    FirebaseApp.configure()
    return true
  }
}

@main
struct SchedoolrApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(authService)
        }
    }
}

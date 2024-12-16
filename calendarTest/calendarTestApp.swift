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
      
<<<<<<< Updated upstream
//    #if DEBUG
//    // Add this before Firebase.configure()
//    let providerFactory = AppCheckDebugProviderFactory()
//    AppCheck.setAppCheckProviderFactory(providerFactory)
//    #endif
      
    #if DEBUG
    let providerFactory = DebugAppCheckProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)
    #endif
=======
      // Configure based on environment
      #if DEBUG
      // Development environment
      let providerFactory = AppCheckDebugProviderFactory()
      AppCheck.setAppCheckProviderFactory(providerFactory)
      
      // Get token through AppCheck directly
      Task {
          do {
              let token = try await AppCheck.appCheck().token(forcingRefresh: true)
              print("Debug App Check token: \(token.token)")
          } catch {
              print("Error getting token: \(error)")
          }
      }
      #else
      // Production environment - using DeviceCheck or App Attest
      if #available(iOS 14.0, *) {
          let providerFactory = AppAttestProviderFactory()
          AppCheck.setAppCheckProviderFactory(providerFactory)
      } else {
          let providerFactory = DeviceCheckProviderFactory()
          AppCheck.setAppCheckProviderFactory(providerFactory)
      }
      #endif
>>>>>>> Stashed changes
      
    FirebaseApp.configure()
    return true
  }
}

@main
struct calendarTestApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
<<<<<<< Updated upstream
            WelcomeView()
                .environmentObject(authService)
=======
            ContentView()
>>>>>>> Stashed changes
        }
    }
}

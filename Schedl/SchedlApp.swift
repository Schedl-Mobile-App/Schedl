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

class SchedlAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
          
        
//        let providerFactory = SchedlAppCheckProviderFactory()         // for production builds
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
          
        return true
    }
}

@main
struct SchedlApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // define an instance of our AuthViewModel to gain access to our log in functions
    @StateObject private var authViewModel = AuthViewModel(hasOnboarded: UserDefaults.standard.hasOnboarded)
    
    var body: some Scene {
        WindowGroup {
            if !authViewModel.hasOnboarded {
                NavigationStack {
                    OnboardingViewOne()
                }
                .environmentObject(authViewModel)
            } else {
                Group {
                    if authViewModel.isLoading {
                        PostLaunchScreenLoadingView()
                    }
                    else if !authViewModel.isLoggedIn {
                        NavigationStack {
                            WelcomeView()
                        }
                        .environmentObject(authViewModel)
                    } else {
                        MainTabBarView()
                            .environmentObject(authViewModel)
                    }
                }
                .task {
                    await authViewModel.persistentLogin()
                }
            }
        }
    }
}

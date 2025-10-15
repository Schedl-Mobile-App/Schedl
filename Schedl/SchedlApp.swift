//
//  calendarTestApp.swift
//  calendarTest
//
//  Created by Salvador Pruneda on 9/2/24.
//

import SwiftUI

@Observable
class TabBarViewModel {
    var isTabBarHidden: Bool = false
}

extension EnvironmentValues {
    @Entry var tabBar = TabBarViewModel()
}

@main
struct SchedlApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // define an instance of our AuthViewModel to gain access to our log in functions
    @StateObject private var vm = AuthViewModel(hasOnboarded: UserDefaults.standard.hasOnboarded)
    @State private var tabBarState = TabBarViewModel()
    
    var body: some Scene {
        WindowGroup {
            if !vm.hasOnboarded {
                NavigationStack {
                    OnboardingViewOne()
                }
                .environmentObject(vm)
//                .environment(\.auth, vm)
            } else {
                Group {
                    if vm.isLoadingLaunchScreen {
                        PostLaunchScreenLoadingView()
                    } else {
                        if !vm.isLoggedIn {
                            NavigationStack {
                                WelcomeView()
                            }
                            .environmentObject(vm)
                            .environment(\.tabBar, tabBarState)
                        } else {
                            MainTabBarView()
                                .environmentObject(vm)
                                .environment(\.tabBar, tabBarState)
                        }
                    }
                }
                .task {
                    await vm.persistentLogin()
                }
                
            }
        }
    }
}

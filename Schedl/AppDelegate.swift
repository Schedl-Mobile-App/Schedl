//
//  AppDelegate.swift
//  Schedl
//
//  Created by David Medina on 6/26/25.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
          
        #if DEBUG
            AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
            AppCheck.setAppCheckProviderFactory(SchedlAppCheckProviderFactory())
        #endif
        
        FirebaseApp.configure()
          
        return true
    }
}

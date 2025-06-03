//
//  DebugAppCheckProviderFactory.swift
//  calendarTest
//
//  Created by David Medina on 12/16/24.
//


//
//  AppCheckProviderFactory.swift
//  calendarTest
//
//  Created by David Medina on 12/14/24.
//

import FirebaseCore
import FirebaseAppCheck

#if DEBUG
class DebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
        
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppCheckDebugProvider(app: app)
    }
}
#endif
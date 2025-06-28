//
//  SchedlAppCheckProviderFactory.swift
//  Schedl
//
//  Created by David Medina on 6/26/25.
//

import Firebase

class SchedlAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}

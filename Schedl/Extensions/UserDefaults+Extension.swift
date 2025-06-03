//
//  UserDefaults+Extension.swift
//  Schedoolr
//
//  Created by David Medina on 5/17/25.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String, CaseIterable {
        case hasOnboarded
    }
    
    var hasOnboarded: Bool {
        get {
            bool(forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        } set {
            set(newValue, forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
    }
    
    func reset() {
            UserDefaultsKeys.allCases.forEach { removeObject(forKey: $0.rawValue) }
        }
}

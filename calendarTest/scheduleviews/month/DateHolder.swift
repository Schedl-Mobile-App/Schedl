//
//  DateHolder.swift
//  calendarTest
//
//  Created by Salvador Pruneda on 9/21/24.
//

import SwiftUI
import Combine

class DateHolder: ObservableObject {
    @Published var currentDate: Date = Date()
    
    func updateDate(to date: Date) {
        currentDate = date
    }
}

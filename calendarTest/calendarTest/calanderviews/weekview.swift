//
//  yearview.swift
//  calendarTest
//
//  Created by Salvador Pruneda on 9/2/24.
//

import SwiftUI

struct weekview: View {
    var body: some View {
        Text(currentMonthString() + " " + currentDayString())
            .font(.title2)
            .padding()

    }
    
    
    func currentMonthString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    func currentDayString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

#Preview {
    weekview()
}

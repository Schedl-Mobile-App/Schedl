//
//  dayview.swift
//  calendarTest
//
//  Created by Salvador Pruneda on 9/2/24.
//

import SwiftUI

struct dayview: View {
    var body: some View {
        Text(weekday())
            .font(.title2)
            .padding()

    }

    
    func weekday() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

#Preview {
    dayview()
}

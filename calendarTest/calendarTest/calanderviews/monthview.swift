//
//  monthview.swift
//  calendarTest
//
//  Created by Salvador Pruneda on 9/2/24.
//

import SwiftUI

struct monthview: View {
    var body: some View {
        Text(currentYearString())
            .font(.title2)
            .padding()

    }
    
    
    func currentYearString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    monthview()
}

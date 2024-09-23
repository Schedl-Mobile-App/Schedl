//
//  MyAccountView.swift
//  calendarTest
//
//  Created by David Medina on 9/19/24.
//

import SwiftUI

struct AccountViewController: View {
    
    @State private var data: [String: Any] = [:]
    @State private var isLoading = true
    
    var body: some View {
        VStack {
                    if isLoading {
                        Text("Loading...")
                            .onAppear {
                                FirebaseManager.shared.fetchData { fetchedData in
                                    if let fetchedData = fetchedData {
                                        self.data = fetchedData
                                    }
                                    self.isLoading = false
                                }
                            }
                    } else {
                        // Display your data here
                        Text("Data: \(data.description)")
                    }
                }
                .padding()
    }
}

#Preview {
    AccountViewController()
}

import SwiftUI

struct buttonview: View {
    var body: some View {
        TabView {
            monthview()
                .tabItem {
                    Label("Month View", systemImage: "calendar.badge.plus")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            weekview()
                .tabItem {
                    Label("Week View", systemImage: "calendar")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            
            dayview()
                .tabItem {
                    Label("Day View", systemImage: "calendar.badge.clock")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
        }
    }
}

#Preview {
    buttonview()
}

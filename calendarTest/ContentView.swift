import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Calendar")
                .font(.largeTitle)
                .fontWeight(.medium)
            
            MainTabBarViewController()
            
        }
    }
}

#Preview {
    ContentView()
}

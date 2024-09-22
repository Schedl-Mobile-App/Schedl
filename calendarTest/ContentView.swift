import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dateHolder: DateHolder
    var body: some View {
        VStack {
            Spacer()
            Text("Calendar")
                .font(.largeTitle)
                .fontWeight(.medium)
            
            MainTabBarViewController()
                .environmentObject(dateHolder)
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DateHolder())
}

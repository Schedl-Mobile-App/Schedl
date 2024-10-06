import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dateHolder: DateHolder
    var body: some View {
        WelcomeViewController()
            .environmentObject(DateHolder())
    }
}

#Preview {
    ContentView()
        .environmentObject(DateHolder())
}

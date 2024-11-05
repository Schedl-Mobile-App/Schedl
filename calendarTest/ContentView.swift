import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dateHolder: DateHolder
    var body: some View {
        WelcomeView()
            .environmentObject(DateHolder())
    }
}

#Preview {
    ContentView()
        .environmentObject(DateHolder())
}

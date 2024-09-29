import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dateHolder: DateHolder
    var body: some View {
        
        LoginViewController()
            .environmentObject(DateHolder())
    }
}

#Preview {
    ContentView()
        .environmentObject(DateHolder())
}

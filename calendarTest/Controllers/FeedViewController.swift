import SwiftUI

struct FeedViewController: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        NavigationLink(destination: EventView()) {
                            EventViewNoEdit()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    FeedViewController()
}

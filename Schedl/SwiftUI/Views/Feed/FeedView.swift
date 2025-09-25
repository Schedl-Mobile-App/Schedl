import SwiftUI

enum FeedDestinations: Hashable {
    case notifications
}

struct FeedView: View {
    
    @StateObject private var feedViewModel: FeedViewModel
    @State var keyboardHeight: CGFloat = 0
    @State var navigateToNotifications = false
    
    init(currentUser: User) {
        _feedViewModel = StateObject(wrappedValue: FeedViewModel(currentUser: currentUser))
    }
    
    @State private var rotateGear = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            List(1...50, id: \.self) { index in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color("SectionalColors"))
                        .frame(width: 28, height: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Item \(index)")
                            .font(.headline)
                            .foregroundStyle(Color("PrimaryText"))
                        Text("This is row number \(index) in the feed.")
                            .font(.subheadline)
                            .foregroundStyle(Color("SecondaryText"))
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationDestination(for: FeedDestinations.self, destination: { destination in
            NotificationsView(currentUser: feedViewModel.currentUser)
        })
        .modifier(NavigationFeedViewModifier())
    }
}

struct NavigationFeedViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationTitle("Feed")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(value: FeedDestinations.notifications, label: {
                            Image(systemName: "bell")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color("NavItemsColors"))
                        })
                    }
                }
        } else {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Feed")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("NavItemsColors"))
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(value: FeedDestinations.notifications, label: {
                            Image(systemName: "bell")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color("NavItemsColors"))
                        })
                    }
                }
        }
    }
}

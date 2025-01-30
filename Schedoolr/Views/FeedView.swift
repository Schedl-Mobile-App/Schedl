import SwiftUI

struct FeedView: View {
    
    @StateObject private var notificationsViewModel: FeedViewModel = FeedViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text("Schedulr")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 25, weight: .bold, design: .monospaced))
                
                Spacer()
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell")
                        .foregroundColor(Color.primary)
                        .font(.system(size: 25))
                }
            }
            .padding()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    if notificationsViewModel.isLoading {
                        VStack(alignment: .center) {
                            ProgressView("Loading...")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 575, alignment: .center)
                    } else if let error = notificationsViewModel.errorMessage {
                        VStack(alignment: .center) {
                            Text("\(error)")
                        }
                        .frame(maxWidth: .infinity, minHeight: 575, alignment: .center)
                    } else if let posts = notificationsViewModel.posts {
                        ForEach(posts) { post in
                            PostView(post: post)
                        }
                    } else {
                        VStack(alignment: .center) {
                            Text("Your friends haven't added any posts yet!")
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .tracking(1)

                        }
                        .frame(maxWidth: .infinity, minHeight: 575, alignment: .center)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                if let user = authService.currentUser {
                    notificationsViewModel.fetchFeed(userId: user.id)
                }
            }
            .onDisappear {
                notificationsViewModel.removeFeedListener()
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(FeedViewModel())
        .environmentObject(AuthService())
}

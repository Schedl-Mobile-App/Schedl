import SwiftUI

struct FeedView: View {
    
    @StateObject private var feedViewModel: FeedViewModel
    
    init(currentUser: User) {
        _feedViewModel = StateObject(wrappedValue: FeedViewModel(currentUser: currentUser))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text("Schedulr")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 25, weight: .bold, design: .monospaced))
                
                Spacer()
                NavigationLink(destination: NotificationsView(currentUser: feedViewModel.currentUser)) {
                    Image(systemName: "bell")
                        .foregroundColor(Color.primary)
                        .font(.system(size: 25))
                }
            }
            .padding()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    if feedViewModel.isLoading {
                        VStack(alignment: .center) {
                            ProgressView("Loading...")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 575, alignment: .center)
                    } else if let error = feedViewModel.errorMessage {
                        VStack(alignment: .center) {
                            Text("\(error)")
                        }
                        .frame(maxWidth: .infinity, minHeight: 575, alignment: .center)
                    } else if let posts = feedViewModel.posts {
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
        }
    }
}

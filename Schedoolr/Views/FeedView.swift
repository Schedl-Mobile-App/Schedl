import SwiftUI

struct FeedView: View {
    
    @StateObject private var viewModel: FeedViewModel = FeedViewModel()
    @EnvironmentObject var userObj: AuthService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let posts = viewModel.posts {
                    ForEach(posts) { post in
                        EventView(post: post)
                    }
                } else if let error = viewModel.errorMessage {
                    Text("\(error)")
                } else {
                    Text("Your friends haven't added any posts yet!")
                }
                
            }
            .padding()
        }
        .onAppear {
            if let user = userObj.currentUser {
                viewModel.fetchFeed(userId: user.id)
            }
        }
        .navigationTitle("Home")
    }
}

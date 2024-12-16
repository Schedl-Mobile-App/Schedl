import SwiftUI

struct FeedView: View {
    
<<<<<<< Updated upstream
    @StateObject private var viewModel: FeedViewModel = FeedViewModel()
    @EnvironmentObject var userObj: AuthService
=======
    @StateObject private var viewModel: FeedViewModel
    @StateObject private var userObj: AuthService
    
    init(viewModel: FeedViewModel =
         FeedViewModel(), userObj: AuthService = AuthService()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _userObj = StateObject(wrappedValue: userObj)
    }
>>>>>>> Stashed changes
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let posts = viewModel.posts {
                    ForEach(posts) { post in
                        EventView(postData: post)
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
<<<<<<< Updated upstream
=======

#Preview {
    FeedView(viewModel: FeedViewModel(), userObj: AuthService())
}
>>>>>>> Stashed changes

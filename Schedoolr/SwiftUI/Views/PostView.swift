import SwiftUI

struct PostView: View {
    @State var post: Post
    
    var body: some View {
        VStack {
            Text(post.title)
                .padding(10)
            Text(post.description)
                .padding(10)
        }
    }
}


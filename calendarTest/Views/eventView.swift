

import SwiftUI

struct EventView: View {
    
    var body: some View {
        Text("In progress")
    }
    
//    @StateObject private var viewModel: FeedViewModel
//    
//    var body: some View {
//        if viewModel.isLoading {
//            ProgressView("Loading...")
//        } else if let posts = viewModel.posts {
//            
//        }
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                
//                // Main
//                VStack(alignment: .leading, spacing: 20) {
//                    
//                    // Title and Time
//                    VStack(alignment: .leading, spacing: 5) {
//                        HStack {
//                            Text(eventTitle)
//                                .font(.system(size: 28, weight: .bold, design: .rounded))
//                                .foregroundColor(.primary)
//                            Spacer()
////                            if(permission){
////                                Button(action: {
////                                    // button actions
////                                    print("Edit title/description")
////                                }) {
////                                    Text("Edit")
////                                        .font(.subheadline)
////                                        .padding(5)
////                                        .background(Color.blue.opacity(0.1))
////                                        .cornerRadius(10)
////                                }
////                            }
//                        }
//                        
//                        Text("Date: " + eventSubtitle)
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        // Event location
//                        Text("Location: " + eventLocation)
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        
//                        // Event creator
//                        Text("Host: " + eventCreator)
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    
//                    // Gallery
//                    VStack(alignment: .leading) {
//                        Text("Gallery")
//                            .font(.headline)
//                        TabView {
//                            ForEach(eventPhotos, id: \.self) { photo in
//                                Image(photo)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(height: 300)
//                                    .clipped()
//                                    .cornerRadius(15)
//                                    .shadow(radius: 5)
//                            }
//                        }
//                        .tabViewStyle(PageTabViewStyle())
//                        .frame(height: 300)
//                        
//                        Spacer().frame(height: 10)
//                        
//                        // Description
//                        VStack(alignment: .leading) {
//                            Text("Description")
//                                .font(.headline)
//                                .padding(.bottom, 5)
//                            Text(eventDescription)
//                                .font(.body)
//                                .foregroundColor(.primary)
//                        }
//                        
//                        if (permission){
//                            Button(action: {
//                                // button actions
//                                print("Add/delete photos")
//                            }) {
//                                Text("Manage Photos")
//                                    .padding(5)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.blue.opacity(0.2))
//                                    .foregroundColor(.blue)
//                                    .cornerRadius(10)
//                            }
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(15)
//                .shadow(radius: 5)
//                
//                // Invited Users
//                VStack(alignment: .leading, spacing: 15) {
//                    Button(action: {
//                        withAnimation {
//                            showInvitedUsers.toggle()
//                        }
//                    }) {
//                        HStack {
//                            Text("Invited Users")
//                                .font(.headline)
//                            Spacer()
//                            Image(systemName: showInvitedUsers ? "chevron.up" : "chevron.down")
//                        }
//                    }
//
//                    if showInvitedUsers {
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 15) {
//                                ForEach(invitedUsers, id: \.self) { user in
//                                    VStack {
//                                        Image(systemName: "person.crop.circle.fill") // temp pic
//                                            .resizable()
//                                            .frame(width: 60, height: 60)
//                                            .clipShape(Circle())
//                                            .shadow(radius: 5)
//                                        Text(user)
//                                            .font(.footnote)
//                                            .foregroundColor(.primary)
//                                    }
//                                }
//                            }
//                        }
//                        if (permission){
//                            Button(action: {
//                                // button actions
//                                print("Invite/remove people")
//                            }) {
//                                Text("Manage Users")
//                                    .padding(5)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.blue.opacity(0.2))
//                                    .foregroundColor(.blue)
//                                    .cornerRadius(10)
//                            }
//                        }
//                    }
//                    
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(15)
//                .shadow(radius: 5)
//                
//                // Comments Section
//                VStack(alignment: .leading, spacing: 15) {
//                    Button(action: {
//                        withAnimation {
//                            showComments.toggle()
//                        }
//                    }) {
//                        HStack {
//                            Text("Comments")
//                                .font(.headline)
//                            Spacer()
//                            Image(systemName: showComments ? "chevron.up" : "chevron.down")
//                        }
//                    }
//
//                    if showComments {
//                        ForEach(comments, id: \.user) { comment in
//                            VStack(alignment: .leading, spacing: 8) {
//                                HStack {
//                                    Image(systemName: "person.circle.fill") // avatar placeholder
//                                        .resizable()
//                                        .frame(width: 40, height: 40)
//                                        .clipShape(Circle())
//                                    VStack(alignment: .leading) {
//                                        Text(comment.user)
//                                            .font(.subheadline)
//                                            .foregroundColor(.secondary)
//                                        Text(comment.commentText)
//                                            .font(.body)
//                                            .foregroundColor(.primary)
//                                    }
//                                    Spacer()
//                                    Button(action: {
//                                        // Like button action
//                                        print("like")
//                                    }) {
//                                        Image(systemName: "heart")
//                                    }
//                                }
//                            }
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(15)
//                        }
//                        
//                        // New Comment Input Field
//                        HStack {
//                            TextField("Add a comment...", text: $newCommentText)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                            Button(action: {
//                                // Add comments
//                                if !newCommentText.isEmpty {
//                                    let newComment = Comment(user: "You", commentText: newCommentText)
//                                    comments.append(newComment)
//                                    newCommentText = ""
//                                }
//                            }) {
//                                Text("Post")
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                        .padding(.top)
//
//                        if(permission){
//                            // Manage Comments Button
//                            Button(action: {
//                                // button action
//                                print("remove comments")
//                            }) {
//                                Text("Manage Comments")
//                                    .padding(5)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.blue.opacity(0.2))
//                                    .foregroundColor(.blue)
//                                    .cornerRadius(10)
//                            }
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .cornerRadius(15)
//                .shadow(radius: 5)
//                
//            }
//            .padding(.horizontal)
//        }
//        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
//        .navigationTitle("Event Details")
//    }
}

#Preview {
    EventView()
}

import SwiftUI

struct Comment {
    let user: String
    let commentText: String
    let postDate: String // Added post date for comments
}

struct EventView: View {
    @State private var eventTitle: String = "Halloween"
    @State private var eventSubtitle: String = "October 31st, 9:00 PM"
    @State private var eventDescription: String = "BOOOOOOM, this event is gonna go CRAZY"
    @State private var eventPostDate: String = "Posted on: November 1, 2024"
    @State private var invitedUsers: [String] = ["User 1", "User 2", "User 3"]
    @State private var eventPhotos: [String] = ["pic1", "pic2", "pic3"] // Local image names
    @State private var comments: [Comment] = [
        Comment(user: "User 1", commentText: "Great event!", postDate: " November 15, 2024"),
        Comment(user: "User 2", commentText: "Can't wait!", postDate: "November 15, 2024"),
        Comment(user: "User 3", commentText: "Looking forward to it!", postDate: "November 15, 2024")
    ]
    @State private var permission: Bool = true // change to swap edit permissions
    @State private var showInvitedUsers: Bool = false
    @State private var showComments: Bool = false

    @State private var eventCreator: String = "Garfield Lasang"
    @State private var eventLocation: String = "123 Party Ave, Fun City"
    
    // Add comments
    @State private var newCommentText: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Main Section: Event Details
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title and Details
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(eventTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            if(permission){
                                Button(action: {
                                    print("Edit title/description")
                                }) {
                                    Text("Edit")
                                        .font(.subheadline)
                                        .padding(5)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        
                        Text("Date: " + eventSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Location: " + eventLocation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Host: " + eventCreator)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(eventPostDate) // Event post date
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    // Gallery
                    VStack(alignment: .leading) {
                        Text("Gallery")
                            .font(.headline)
                        TabView {
                            ForEach(eventPhotos, id: \.self) { photo in
                                Image(photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 300)
                                    .clipped()
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 300)
                        
                        Spacer().frame(height: 10)
                        
                        // Description
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text(eventDescription)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        if (permission){
                            Button(action: {
                                print("Add/delete photos")
                            }) {
                                Text("Manage Photos")
                                    .padding(5)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // Invited Users
                VStack(alignment: .leading, spacing: 15) {
                    Button(action: {
                        withAnimation {
                            showInvitedUsers.toggle()
                        }
                    }) {
                        HStack {
                            Text("Invited Users")
                                .font(.headline)
                            Spacer()
                            Image(systemName: showInvitedUsers ? "chevron.up" : "chevron.down")
                        }
                    }

                    if showInvitedUsers {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(invitedUsers, id: \.self) { user in
                                    VStack {
                                        Image(systemName: "person.crop.circle.fill") // temp pic
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .shadow(radius: 5)
                                        Text(user)
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        if (permission){
                            Button(action: {
                                print("Invite/remove people")
                            }) {
                                Text("Manage Users")
                                    .padding(5)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // Comments Section
                VStack(alignment: .leading, spacing: 15) {
                    Button(action: {
                        withAnimation {
                            showComments.toggle()
                        }
                    }) {
                        HStack {
                            Text("Comments")
                                .font(.headline)
                            Spacer()
                            Image(systemName: showComments ? "chevron.up" : "chevron.down")
                        }
                    }

                    if showComments {
                        ForEach(comments, id: \.user) { comment in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "person.circle.fill") // Avatar placeholder
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading) {
                                        Text(comment.user)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(comment.commentText)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text(comment.postDate) // Comment post date
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button(action: {
                                        print("like")
                                    }) {
                                        Image(systemName: "heart")
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        }
                        
                        // New Comment Input Field
                        HStack {
                            TextField("Add a comment...", text: $newCommentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                if !newCommentText.isEmpty {
                                    let newComment = Comment(user: "You", commentText: newCommentText, postDate: "November 19, 2024")
                                    comments.append(newComment)
                                    newCommentText = ""
                                }
                            }) {
                                Text("Post")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top)

                        if(permission){
                            Button(action: {
                                print("remove comments")
                            }) {
                                Text("Manage Comments")
                                    .padding(5)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
        .navigationTitle("Event Details")
    }
}

#Preview {
    EventView()
}

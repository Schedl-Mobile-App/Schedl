//
//  EventPost.swift
//  Schedl
//
//  Created by David Medina on 9/22/25.
//

import SwiftUI

struct EventPostView: View {
    @State private var isLiked = false
    @State private var likeCount = 24
    @State private var commentCount = 8
    @State private var showingComments = false
    
    let event = EventPost(
        userAvatar: "person.crop.circle.fill",
        userName: "Sarah Chen",
        userHandle: "@sarahc",
        eventTitle: "Coffee & Catch Up",
        eventTime: "Today at 2:30 PM",
        location: "Blue Bottle Coffee, Hayes Valley",
        taggedUsers: ["@mikej", "@emmasmith", "@alexk"],
        timeAgo: "15 min ago"
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Post Header
            HStack(alignment: .top, spacing: 12) {
                // User Avatar
                Image(systemName: event.userAvatar)
                    .font(.title2)
                    .foregroundColor(.orange.opacity(0.8))
                    .frame(width: 42, height: 42)
                    .background(
                        LinearGradient(
                            colors: [.orange.opacity(0.1), .pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    // User Info
                    HStack {
                        Text(event.userName)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(event.userHandle)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(event.timeAgo)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Auto-generated post text
                    Text("Just created an event from my calendar ✨")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Event Card
            VStack(spacing: 0) {
                // Event Header with gradient background
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("FROM YOUR CALENDAR")
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(0.5)
                        
                        Spacer()
                        
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Text(event.eventTitle)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(event.eventTime)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.4),
                            Color(red: 1.0, green: 0.5, blue: 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Event Details
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "location")
                            .font(.subheadline)
                        
                        Text(event.location)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Tagged Users
                    if !event.taggedUsers.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "person.2")
                                    .font(.subheadline)
                                
                                Text("Invited Friends")
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                ForEach(event.taggedUsers, id: \.self) { user in
                                    Text(user)
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(.orange.opacity(0.1))
                                        )
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 0.5)
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Interaction Bar
            HStack(spacing: 24) {
                // Like Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                        likeCount += isLiked ? 1 : -1
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(.subheadline, weight: .medium))
                            .foregroundColor(isLiked ? .red : .secondary)
                            .scaleEffect(isLiked ? 1.1 : 1.0)
                        
                        if likeCount > 0 {
                            Text("\(likeCount)")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Comment Button
                Button(action: { showingComments = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .font(.system(.subheadline, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if commentCount > 0 {
                            Text("\(commentCount)")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Share Button
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(.subheadline, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingComments) {
            CommentsView(commentCount: $commentCount)
        }
    }
}

// Supporting Views
struct CommentsView: View {
    @Binding var commentCount: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Comments coming soon...")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarElements()
        }
    }
}

// Data Models
struct EventPost {
    let userAvatar: String
    let userName: String
    let userHandle: String
    let eventTitle: String
    let eventTime: String
    let location: String
    let taggedUsers: [String]
    let timeAgo: String
}

// Navigation Bar Extension
extension View {
    func navigationBarElements() -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    // Dismiss logic would go here
                }
                .font(.system(.subheadline, design: .rounded, weight: .medium))
            }
        }
    }
}

// Preview
struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EventPostView()
                
                // Additional posts could go here
                Rectangle()
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .overlay(
                        Text("Next Post...")
                            .foregroundColor(.secondary)
                    )
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}

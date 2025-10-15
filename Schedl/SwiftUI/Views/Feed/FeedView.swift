//
//  FeedView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct FeedView: View {
    
    @StateObject private var vm: FeedViewModel
    
    init(currentUser: User) {
        _vm = StateObject(wrappedValue: FeedViewModel(currentUser: currentUser))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                List {
                    ForEach(1..<4) { _ in
                        PostCell(currentUser: mockUser)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden, edges: .top)
                            .listRowSeparator(.visible, edges: .bottom)
                            .alignmentGuide(.listRowSeparatorLeading) {
                                $0[.leading]
                            }
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
            .modifier(NavigationFeedViewModifier(currentUser: mockUser))
        }
    }
}

struct NavigationFeedViewModifier: ViewModifier {
    
    @Environment(\.router) var coordinator: Router
    let currentUser: User
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationTitle("Feed")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            coordinator.push(page: .notifications(currentUser: currentUser))
                        }, label: {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color("NavItemsColors"))
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            coordinator.push(page: .notifications(currentUser: currentUser))
                        }, label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color("NavItemsColors"))
                        })
                    }
                }
        } else {
            content
                .navigationTitle("Feed")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            coordinator.push(page: .notifications(currentUser: currentUser))
                        }, label: {
                            Image(systemName: "bell")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color("NavItemsColors"))
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            coordinator.push(page: .notifications(currentUser: currentUser))
                        }, label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color("NavItemsColors"))
                        })
                    }
                }
        }
    }
}

import PhotosUI
import Kingfisher

struct PostCell: View {
    
    @State private var imageLoadingError = false
    let currentUser: User
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                EventInfoView(user: currentUser)
                    .padding(.horizontal)
                
                KFImage(URL(string: "https://iso.500px.com/wp-content/uploads/2013/08/11834033-1170.jpeg"))
                    .placeholder { ProgressView() }
                    .loadDiskFileSynchronously()
                    .fade(duration: 0.25)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 275)
                
                HStack {
                    Text("Finally got a photo of this place...")
                }
                .padding(.horizontal)
            }
            
            HStack {
                Text("Today, 8:45PM")
                    .font(.caption)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color("SecondaryText"))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.vertical)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct PostProfileImage: View {
    
    @State private var imageLoadingError = false
    var profileImage: String
    var displayName: String
    
    var body: some View {
        if !imageLoadingError {
            KFImage.url(URL(string: profileImage))
                .placeholder {
                    ProgressView()
                }
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .onProgress { receivedSize, totalSize in  }
                .onSuccess { result in  }
                .onFailure { _ in
                    self.imageLoadingError = true
                }
                .resizable() // Makes the image resizable
                .scaledToFill() // Fills the frame, preventing distortion
                .frame(width: 41.75, height: 41.75) // Sets a square frame for the circle
                .clipShape(Circle()) // Clips the view into a circle shape
                .alignmentGuide(.listRowSeparatorLeading) {
                                    $0[.leading]
                                }
        } else {
            Circle()
                .strokeBorder(Color("ButtonColors"), lineWidth: 1.75)
                .background(Color.clear)
                .frame(width: 41.75, height: 41.75)
                .overlay {
                    // Show while loading or if image fails to load
                    Circle()
                        .fill(Color("SectionalColors"))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("\(displayName.first?.uppercased() ?? "J")\(displayName.last?.uppercased() ?? "D")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(-0.25)
                                .foregroundStyle(Color("PrimaryText"))
                                .multilineTextAlignment(.center)
                        }
                }
        }
    }
}

struct EventInfoView: View {
    
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            PostProfileImage(profileImage: user.profileImage, displayName: user.displayName)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Trip to the Grand Canyon")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("March 18, 2025")
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color("SecondaryText"))
                    
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(Color("SecondaryText"))
                        Text("Grand Canyon National Park, AZ 86023")
                            .font(.caption)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color("SecondaryText"))
                            .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

//// Simple image grid view
//struct PostImagesView: View {
//    let imageUrls: [String]
//
//    var body: some View {
//        let imageCount = imageUrls.count
//
//        switch imageCount {
//        case 1:
//            SingleImageView(imageUrl: imageUrls[0])
//        case 2:
//            TwoImagesView(imageUrls: imageUrls)
//        case 3:
//            ThreeImagesView(imageUrls: imageUrls)
//        case 4...:
//            FourImagesView(imageUrls: Array(imageUrls.prefix(4)))
//        default:
//            EmptyView()
//        }
//    }
//}
//
//struct SingleImageView: View {
//    let imageUrl: String
//
//    var body: some View {
//        AsyncImage(url: URL(string: imageUrl)) { image in
//            image
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//        } placeholder: {
//            Rectangle()
//                .fill(Color("ImagePlaceholder"))
//                .overlay(
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                )
//        }
//        .frame(maxHeight: 300)
//        .clipped()
//        .cornerRadius(12)
//    }
//}
//
//struct TwoImagesView: View {
//    let imageUrls: [String]
//
//    var body: some View {
//        HStack(spacing: 2) {
//            ForEach(0..<min(2, imageUrls.count), id: \.self) { index in
//                AsyncImage(url: URL(string: imageUrls[index])) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } placeholder: {
//                    Rectangle()
//                        .fill(Color("ImagePlaceholder"))
//                }
//                .frame(height: 200)
//                .clipped()
//                .cornerRadius(8)
//            }
//        }
//    }
//}
//
//struct ThreeImagesView: View {
//    let imageUrls: [String]
//
//    var body: some View {
//        HStack(spacing: 2) {
//            AsyncImage(url: URL(string: imageUrls[0])) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//            } placeholder: {
//                Rectangle()
//                    .fill(Color("ImagePlaceholder"))
//            }
//            .frame(height: 200)
//            .clipped()
//            .cornerRadius(8)
//
//            VStack(spacing: 2) {
//                ForEach(1..<min(3, imageUrls.count), id: \.self) { index in
//                    AsyncImage(url: URL(string: imageUrls[index])) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Rectangle()
//                            .fill(Color("ImagePlaceholder"))
//                    }
//                    .frame(height: 99)
//                    .clipped()
//                    .cornerRadius(8)
//                }
//            }
//        }
//    }
//}
//
//struct FourImagesView: View {
//    let imageUrls: [String]
//
//    var body: some View {
//        LazyVGrid(columns: [
//            GridItem(.flexible(), spacing: 2),
//            GridItem(.flexible(), spacing: 2)
//        ], spacing: 2) {
//            ForEach(0..<min(4, imageUrls.count), id: \.self) { index in
//                AsyncImage(url: URL(string: imageUrls[index])) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } placeholder: {
//                    Rectangle()
//                        .fill(Color("ImagePlaceholder"))
//                }
//                .frame(height: 120)
//                .clipped()
//                .cornerRadius(8)
//            }
//        }
//    }
//}

#Preview {
    FeedView(currentUser: mockUser)
}

let mockUser = User(id: "EklrnJ8NRuVjWl8vpoAiJUwyNsk1", email: "djay0628@gmail.com", displayName: "David Medina", username: "djay0628", profileImage: "https://firebasestorage.googleapis.com:443/v0/b/penny-b4f01.firebasestorage.app/o/users%2FEklrnJ8NRuVjWl8vpoAiJUwyNsk1%2FprofileImages%2Fprofile_87907532-2551-479F-8153-24B8092D2504.jpg?alt=media&token=000e42ff-e566-4964-a424-016f81da818e", numOfEvents: 10, numOfFriends: 2, numOfPosts: 5)
//
//struct PostView: View {
//
//
//    var body: some View {
//        ZStack {
//
//            Color("BackgroundColor")
//                .ignoresSafeArea()
//
//            ScrollView(.vertical, showsIndicators: false) {
//                Spacer()
//                    .frame(height: 100)
//                VStack {
//                    HStack {
//                        PostProfileCell(user: mockUser)
//                    }
//                    .padding(.horizontal)
//
//                    VStack {
//
//
//
//                        KFImage(URL(string: "https://iso.500px.com/wp-content/uploads/2013/08/11834033-1170.jpeg"))
//                            .placeholder { ProgressView() }
//                            .loadDiskFileSynchronously()
//                            .fade(duration: 0.25)
//                            .resizable()
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 400)
////                            .clipShape(RoundedRectangle(cornerRadius: 25))
////                            .shadow(color: .gray, radius: 3)
//                    }
//                }
//                .padding(.vertical)
//                .background(.regularMaterial)
//            }
//        }
//    }
//}
//
//#Preview {
//    PostView()
//}
//
//struct PostProfileCell: View {
//
//    let user: User
//    @State private var imageLoadingError = false
//
//    var body: some View {
//        HStack(spacing: 15) {
//            ThumbnailProfileImageView(profileImage: user.profileImage, displayName: user.displayName)
//
//            VStack(alignment: .leading, spacing: 1) {
//                Text("\(user.displayName)")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .fontDesign(.rounded)
//                    .tracking(-0.25)
//                    .foregroundStyle(Color("PrimaryText"))
//                    .multilineTextAlignment(.leading)
//                HStack(spacing: 0) {
//                    Text("@")
//                        .font(.subheadline)
//                        .fontWeight(.medium)
//                        .fontDesign(.rounded)
//                        .foregroundStyle(Color("SecondaryText"))
//                        .multilineTextAlignment(.leading)
//                    Text("\(user.username)")
//                        .font(.subheadline)
//                        .fontWeight(.medium)
//                        .fontDesign(.rounded)
//                        .tracking(1.05)
//                        .foregroundStyle(Color("SecondaryText"))
//                        .multilineTextAlignment(.leading)
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}





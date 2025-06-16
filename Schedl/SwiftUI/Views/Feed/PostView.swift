import SwiftUI
import PhotosUI

struct PostView: View {
//    @State var post: Post
    @State private var currentPage = 0
    @State var selectedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State var showCommentArea: Bool = false
    var images = ["pic1", "pic2", "pic3"]
    @State private var commentTextInput = ""
    private var showSubmitComment: Bool {
        return !commentTextInput.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Circle()
                    .strokeBorder(Color(hex: 0x3C859E), lineWidth: 1.75)
                    .background(Color.clear)
                    .frame(width: 31.75, height: 31.75)
                    .overlay {
                        Circle()
                            .fill(Color(hex: 0xe0dad5))
                            .frame(width: 30, height: 30)
                            .overlay {
                                Text("JD")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .multilineTextAlignment(.center)
                            }
                    }
                
                Text("David Medina")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(0.1)
                    .foregroundStyle(Color(hex: 0x333333))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text("2h ago")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .tracking(1.15)
                    .foregroundStyle(Color(hex: 0x666666))
                    .multilineTextAlignment(.leading)
            }
            
            ZStack() {
                TabView(selection: $currentPage) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 250)
                .cornerRadius(10)
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color(.black.opacity(0.1)))
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 250)
//                    .overlay {
//                        if let image = selectedImage {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 250)
//                        }
//                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
//                PhotosPicker(selection: $pickerItem, matching: .images) {
//                    Circle()
//                        .foregroundStyle(Color(hex: 0x6d8a96))
//                        .frame(maxWidth: 30, maxHeight: 30)
//                        .foregroundStyle(.clear)
//                        .overlay {
//                            Image(systemName: "plus")
//                                .font(.system(size: 14, weight: .heavy))
//                                .foregroundStyle(.white)
//                                .containerShape(Circle())
//                        }
//                        .offset(x: 5, y: -5)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            HStack {
                Button(action: {
                    
                }) {
                    Image(systemName: "heart")
                        .imageScale(.medium)
                }
                Button(action: {
                    showCommentArea.toggle()
                }) {
                    Image(systemName: "hand.thumbsup")
                        .imageScale(.medium)
                }
            }
            Group {
                Text("djay0628")
                    .font(.body)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .tracking(1.15) +
                Text("What an amazing sight that I've caught on my camera today!")
                    .font(.body)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .tracking(1.15)
            }
            
            if !showCommentArea {
                Button(action: {
                    showCommentArea.toggle()
                }) {
                    Text("View comments")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundStyle(.gray)
                        .tracking(1.15)
                }
            }
            
            if showCommentArea {
                VStack(spacing: 5) {
                    TextField("Leave a comment...", text: $commentTextInput, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding()
                        .font(.headline)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .tracking(1.15)
                    
                    if showSubmitComment {
                        Button(action: {
                            print("Submit action here...")
                        }) {
                            Text("Submit")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(0.1)
                                .foregroundColor(Color.white)
                        }
                        .padding()
                        .background {
                            Capsule()
                                .fill(Color(hex: 0x3C859E))
                                .frame(height: 35)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                        .padding(.bottom)
                    }
                }
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .animation(.easeInOut(duration: 0.2), value: showSubmitComment)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
        }
        
//        .onChange(of: pickerItem) {
//            Task {
//                if let imageData = try await pickerItem?.loadTransferable(type: Data.self) {
//                    selectedImage = UIImage(data: imageData)
//                }
//            }
//        }
    }
}

#Preview {
    PostView()
}


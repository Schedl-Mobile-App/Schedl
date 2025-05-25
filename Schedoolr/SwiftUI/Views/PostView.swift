import SwiftUI
import PhotosUI

struct PostView: View {
//    @State var post: Post
    @State var selectedImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
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
                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color(hex: 0x333333))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Text("2h ago")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0x666666))
                    .multilineTextAlignment(.leading)
            }
            
            ZStack() {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.black.opacity(0.1)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .overlay {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Circle()
                        .foregroundStyle(Color(hex: 0x6d8a96))
                        .frame(maxWidth: 30, maxHeight: 30)
                        .foregroundStyle(.clear)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(.white)
                                .containerShape(Circle())
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            
            Text("What an amazing sight that I've caught on my camera today!")
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
        }
        .onChange(of: pickerItem) {
            Task {
                if let imageData = try await pickerItem?.loadTransferable(type: Data.self) {
                    selectedImage = UIImage(data: imageData)
                }
            }
        }
    }
}


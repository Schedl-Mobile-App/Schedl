import SwiftUI

struct FeedView: View {
    
    @StateObject private var feedViewModel: FeedViewModel
    @State var keyboardHeight: CGFloat = 0
    
    init(currentUser: User) {
        _feedViewModel = StateObject(wrappedValue: FeedViewModel(currentUser: currentUser))
    }
    
    @State private var rotateGear = false
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center) {
                    Text("Schedl")
                        .foregroundStyle(Color.primary)
                        .font(.system(size: 25, weight: .bold, design: .monospaced))
                    
                    Spacer()
                    NavigationLink(destination: NotificationsView(currentUser: feedViewModel.currentUser)) {
                        Image(systemName: "bell")
                            .font(.system(size: 26))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: 0x333333))
                    }
                }
                .padding()
                
                Spacer()
                
                VStack(alignment: .center, spacing: 24) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 85, height: 85)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.accentColor, Color(.systemGray)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(rotateGear ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 4)
                                .repeatForever(autoreverses: false),
                            value: rotateGear
                        )
                        .onAppear { rotateGear = true }
                    
                    Text("Under Construction")
                        .font(.title2)
                        .fontDesign(.monospaced)
                        .fontWeight(.bold)
                        .tracking(-0.25)
                        .foregroundColor(Color(hex: 0x666666))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        
        //        ZStack {
        //            Color(hex: 0xf7f4f2)
        //                .ignoresSafeArea()
        //
        //            VStack(alignment: .leading, spacing: 20) {
        //                HStack(alignment: .center) {
        //                    Text("Schedl")
        //                        .foregroundStyle(Color.primary)
        //                        .font(.system(size: 25, weight: .bold, design: .monospaced))
        //
        //                    Spacer()
        //                    NavigationLink(destination: NotificationsView(currentUser: feedViewModel.currentUser)) {
        //                        Image(systemName: "bell")
        //                            .font(.system(size: 26))
        //                            .fontWeight(.semibold)
        //                            .foregroundStyle(Color(hex: 0x333333))
        //                    }
        //                }
        //                .padding()
        //
        //                if feedViewModel.isLoading {
        //                    Spacer()
        //                    ProgressView("Loading...")
        //                        .font(.headline)
        //                        .fontWeight(.medium)
        //                        .fontDesign(.rounded)
        //                        .tracking(1.05)
        //                        .multilineTextAlignment(.center)
        //                        .padding(.horizontal)
        //                    Spacer()
        //                } else if let error = feedViewModel.errorMessage {
        //                    Text(error)
        //                        .font(.headline)
        //                        .fontWeight(.medium)
        //                        .fontDesign(.rounded)
        //                        .tracking(1.05)
        //                        .multilineTextAlignment(.center)
        //                        .padding(.horizontal)
        //                } else if true {
        //                    ScrollView(.vertical, showsIndicators: false) {
        //                        LazyVStack {
        //                            ForEach(1..<10) {_ in
        //                                PostView()
        //                            }
        //                        }
        //                        .padding(.horizontal)
        //                        .keyboardHeight($keyboardHeight)
        //                        .animation(.easeIn(duration: 0.16), value: keyboardHeight)
        //                        .offset(y: -keyboardHeight / 2)
        //                        .padding(.bottom)
        //                    }
        //                    .scrollDismissesKeyboard(.immediately)
        //                } else {
        //                    Spacer()
        //                    Text("Your friends haven't added any posts yet!")
        //                        .font(.headline)
        //                        .fontWeight(.medium)
        //                        .fontDesign(.rounded)
        //                        .tracking(1.05)
        //                        .multilineTextAlignment(.center)
        //                        .padding(.horizontal)
        //                    Spacer()
        //                }
        //            }
        //            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        //        }
    }
}

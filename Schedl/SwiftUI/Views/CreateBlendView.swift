//
//  CreateBlendView.swift
//  Schedl
//
//  Created by David Medina on 8/5/25.
//

import SwiftUI

class BlendViewModel: ObservableObject {
    
    var invitedUsersForEvent: [User] = []
    private var selectedBlend: Blend?
    
    @Published var shouldDismiss: Bool = false
    
    @Published var availabilityList: [FriendAvailability] = []
    @Published var userFriends: [User] = []
    @Published var selectedFriends: [User] = []
    
    @Published var titleError: String = ""
    @Published var invitedUsersError: String = ""
    @Published var colorsError: String = ""
    @Published var submitError: String = ""
    
    // Binding values to trigger/dismiss sheets/pickers
    
    @Published var showInviteUsersSheet: Bool = false
    @Published var showColorPickerSheet: Bool = false
    @Published var hasTriedSubmitting = false
    
    @Published var showingColorPickerForUserId: String? = nil
    
    // at some point, users will be able to limit who can edit in a Blend
    var userCanEdit: Bool {
        return true
    }
    
//    var selectedColor: String {
//        if let color = eventColor {
//            return color.toHex()!
//        }
//        // default Schedl teal color of the event if a user doesn't select one
//        return "3C859E"
//    }
    
    @Published var isLoading: Bool = false      // Indicates loading state
    @Published var errorMessage: String?        // Holds error messages if any
    @Published var eventCreatorName: String = ""
    
    private var userService: UserServiceProtocol
    private var scheduleService: ScheduleServiceProtocol
    private var eventService: EventServiceProtocol
    private var notificationService: NotificationServiceProtocol
    
    @Published var title: String? = nil
    @Published var scheduleIds: [String] = []
    @Published var userColors: [String: Color] = [:]
    
    private var currentUser: User
    
    init(currentUser: User, scheduleService: ScheduleServiceProtocol = ScheduleService.shared, userService: UserServiceProtocol = UserService.shared, eventService: EventServiceProtocol = EventService.shared, notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.currentUser = currentUser
        self.scheduleService = scheduleService
        self.userService = userService
        self.notificationService = notificationService
        self.eventService = eventService
        
    }
    
    @MainActor func createBlend() async {
        guard let title = title else { return }
        guard selectedFriends.count > 0 else { return }
        guard userColors.count > 0 else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let scheduleId = try await scheduleService.fetchScheduleId(userId: currentUser.id)
            let blendId = try await scheduleService.createBlendSchedule(ownerId: currentUser.id, scheduleId: scheduleId, title: title, invitedUsers: selectedFriends.map(\.id), colors: userColors.mapValues { $0.toHex()! })
            try await notificationService.sendBlendInvites(senderId: currentUser.id, username: currentUser.username, profileImage: currentUser.profileImage, toUserIds: selectedFriends.map(\.id), blendId: blendId)
            
            shouldDismiss = true
            
            self.isLoading = false
        } catch {
            print(error.localizedDescription)
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchFriends() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            self.userFriends = try await userService.fetchUserFriends(userId: currentUser.id)
            
            self.isLoading = false
        } catch {
            self.errorMessage = "Please fill out the event date, start time, and end time to check if your friends are available!"
            self.isLoading = false
        }
    }
}

struct CreateBlendView: View {
    
    @EnvironmentObject var tabBarState: TabBarState
    @StateObject var blendViewModel: BlendViewModel
    @FocusState var isFocused: Bool
    @Binding var shouldReloadData: Bool
    
    @Environment(\.dismiss) var dismiss
    
    init(currentUser: User, shouldReloadData: Binding<Bool>) {
        _blendViewModel = StateObject(wrappedValue: BlendViewModel(currentUser: currentUser))
        _shouldReloadData = Binding(projectedValue: shouldReloadData)
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0xf7f4f2)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    Button(action: {
                        tabBarState.hideTabbar = false
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.primary)
                    }
                    
                    
                    Text("Create Blend")
                        .foregroundStyle(Color(hex: 0x333333))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding([.horizontal, .top])
                .frame(maxWidth: .infinity)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Fill out the details below to create a blend with your friends!")
                            .font(.body)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(hex: 0x333333))
                            .padding(.vertical, 8)
                        
                        // view for event title input
                        BlendTitleView(title: $blendViewModel.title, isFocused: $isFocused, hasTriedSubmitting: $blendViewModel.hasTriedSubmitting, titleError: $blendViewModel.titleError)
                        
                        // view for inviting friends selection
                        EventInviteesView(selectedFriends: $blendViewModel.selectedFriends, showInviteUsersSheet: $blendViewModel.showInviteUsersSheet)
                            .sheet(isPresented: $blendViewModel.showInviteUsersSheet) {
                                AddUsersToBlend(blendViewModel: blendViewModel)
                            }
                        
                        // view for event color selection
//                        EventColorView(eventColor: $blendViewModel.eventColor)
                        BlendColorsForInvitees(selectedFriends: $blendViewModel.selectedFriends, showColorPickerSheet: $blendViewModel.showColorPickerSheet, colors: $blendViewModel.userColors, showColorPickerForUserId: $blendViewModel.showingColorPickerForUserId)
                            .sheet(isPresented: $blendViewModel.showColorPickerSheet) {
                                BlendColorPickerSheet(colors: $blendViewModel.userColors, userId: $blendViewModel.showingColorPickerForUserId)
                            }
                        
                        Button(action: {
                            Task {
                                await blendViewModel.createBlend()
                                if blendViewModel.shouldDismiss {
                                    shouldReloadData = true
                                    dismiss()
                                }
                            }
                        }, label: {
                            Text("Create Blend")
                                .foregroundColor(Color(hex: 0xf7f4f2))
                                .font(.headline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .tracking(0.1)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: 0x3C859E))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical, 8)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical)
                    .padding(.horizontal, 25)
                    .simultaneousGesture(TapGesture().onEnded {
                        isFocused = false
                        if blendViewModel.hasTriedSubmitting {
                            blendViewModel.hasTriedSubmitting = false
                        }
                    })
                }
                .defaultScrollAnchor(.top, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .sizeChanges)
                .scrollDismissesKeyboard(.immediately)
                .onTapGesture {
                    isFocused = false
                }
            }
            .padding(.bottom, 0.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(tabBarState.hideTabbar ? .hidden : .visible, for: .tabBar)
    }
}

struct AddUsersToBlend: View {
    
    @ObservedObject var blendViewModel: BlendViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State var searchText: String = ""
    @FocusState var isSearching: Bool?
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return blendViewModel.userFriends
        } else {
            let filteredResults = blendViewModel.userFriends.filter { user in
                let startsWith = user.displayName.lowercased().hasPrefix(searchText.lowercased())
                let endsWith = user.displayName.lowercased().hasSuffix(searchText.lowercased())
                
                return startsWith || endsWith
            }
            
            return filteredResults
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .imageScale(.medium)
                    }
                    
                    TextField("Search friends", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .foregroundStyle(Color(hex: 0x333333))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($isSearching, equals: true)
                    
                    Spacer()
                    
                    Button("Clear", action: {
                        searchText = ""
                    })
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
                    .tracking(-0.25)
                    .foregroundStyle(Color(hex: 0x3C859E))
                    .opacity(!searchText.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: searchText)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(maxWidth: .infinity, alignment: .center)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredUsers, id: \.self.id) { friend in
                            InvitedUserCell(friend: friend, selectedFriends: $blendViewModel.selectedFriends)
                        }
                    }
                    .padding(.vertical)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .padding(.horizontal)
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onTapGesture {
                isSearching = nil
            }
        }
        .presentationDetents([.medium, .large])
        .task {
            await blendViewModel.fetchFriends()
        }
    }
}

struct BlendTitleView: View {
    
    @Binding var title: String?
    var titleBinding: Binding<String> {
        Binding(
            get: { title ?? "" },
            set: { newValue in
                title = newValue.isEmpty ? nil : newValue
            }
        )
    }
    var isFocused: FocusState<Bool>.Binding
    @Binding var hasTriedSubmitting: Bool
    @Binding var titleError: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .top, spacing: 0) {
            
                TextField("Blend Name", text: titleBinding, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(hex: 0x333333))
                    .tracking(0.1)
                    .focused(isFocused)
                    .autocorrectionDisabled(true)
                
                Spacer()
                Button(action: {
                    title = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color(hex: 0x333333))
                }
                .hidden(title == nil)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && title == nil ? Color(hex: 0xE84D3D) : Color.gray, lineWidth: 1)
            }
            
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 4)
                    Text("Blend Name")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                    Spacer()
                        .frame(width: 4)
                }
                .background {
                    Color(hex: 0xf7f4f2)
                }
                .padding(.leading)
                .offset(y: -10)
                .opacity(isFocused.wrappedValue || title != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
                
                Text(titleError)
                    .font(.footnote)
                    .padding(.leading)
                    .offset(y: geometry.size.height * CGFloat(1.05))
                    .foregroundStyle(.red)
                    .opacity(hasTriedSubmitting && !titleError.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasTriedSubmitting)
            }
        }
        .padding(.vertical, 8)
        .padding(.bottom, hasTriedSubmitting && !titleError.isEmpty ? 4 : 0)
    }
}

struct BlendColorsForInvitees: View {
    
    @Binding var selectedFriends: [User]
    @Binding var showColorPickerSheet: Bool
    @Binding var colors: [String: Color]
    @Binding var showColorPickerForUserId: String?
    
    var body: some View {
        Group {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    let enumeratedFriends = Array(selectedFriends.enumerated())
                    ForEach(enumeratedFriends, id: \.element.id) { index, user in
                        let userColor = colors[user.id]
                        HStack {
                            InvitedUserRow(user: user)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            
                            Spacer()
                            
                            Button(action: {
                                showColorPickerForUserId = user.id
                                showColorPickerSheet = true
                            }) {
                                if userColor == nil {
                                    Image(systemName: "paintbrush")
                                        .foregroundColor(Color(hex: 0x333333))
                                        .imageScale(.large)
                                } else {
                                    
                                    HStack(alignment: .center, spacing: 3) {
                                        Image(systemName: "paintbrush")
                                            .foregroundColor(Color(hex: 0x333333))
                                            .imageScale(.large)
                                        
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(userColor ?? Color.clear)
                                            .containerRelativeFrame(.vertical) { height, _ in height * 0.0325 }
                                            .containerRelativeFrame(.horizontal) { width, _ in width * 0.125 }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                }
                
                GeometryReader { geometry in
                    HStack {
                        Spacer()
                            .frame(width: 4)
                        Text("Blend Colors")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                        Spacer()
                            .frame(width: 4)
                    }
                    .opacity(!selectedFriends.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedFriends.isEmpty)
                    .background {
                        Color(hex: 0xf7f4f2)
                    }
                    .padding(.leading)
                    .offset(y: -10)
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: !selectedFriends.isEmpty)
        .padding(.vertical, 8)
    }
}

struct BlendColorPickerSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    let palettes: [ColorPalette] = [ColorPalette.pastel, ColorPalette.rustic, ColorPalette.foresty, ColorPalette.monochrome]
    @State var selectedColor: Color = Color.clear
    @Binding var colors: [String: Color]
    @Binding var userId: String?
    @State var sheetPresentationState: PresentationDetent = .medium
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                switch sheetPresentationState {
                case .medium:
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(palettes, id: \.name) { palette in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(palette.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .padding(.leading)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(palette.colors, id: \.self) { color in
                                            Button(action: {
                                                selectedColor = color
                                                guard let userId = userId else { return }
                                                colors[userId] = color
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(color)
                                                }
                                                .scaleEffect(selectedColor.toHex() == color.toHex() ? 1.125 : 1)
                                                .frame(width: 44, height: 44)
                                                .contentShape(Circle())
                                                .animation(.easeInOut(duration: 0.3), value: selectedColor.toHex() == color.toHex())
                                            }
                                            .frame(width: 50, height: 50)
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.leading)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                case .large:
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(palettes, id: \.name) { palette in
                            VStack(alignment: .leading) {
                                Text(palette.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .foregroundStyle(Color(hex: 0x333333))
                                
                                LazyVGrid(columns: columns) {
                                    ForEach(palette.colors, id: \.self) { color in
                                        Button(action: {
                                            selectedColor = color
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(color)
                                            }
                                            .scaleEffect(selectedColor.toHex() == color.toHex() ? 1.125 : 1)
                                            .frame(width: 44, height: 44)
                                            .contentShape(Circle())
                                            .animation(.easeInOut(duration: 0.3), value: selectedColor.toHex() == color.toHex())
                                        }
                                        .frame(width: 44, height: 44)
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                default:
                    EmptyView()
                    
                }
            }
            .navigationTitle("Select Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large], selection: $sheetPresentationState)
    }
}


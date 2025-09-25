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
    @Published var userColors: [UserMappedBlendColor] = []
    
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
            let userIds = selectedFriends.map { InvitedUser(userId: $0.id, status: "pending") }
            try await scheduleService.createBlendSchedule(ownerId: currentUser.id, scheduleId: scheduleId, title: title, invitedUsers: userIds, colors: userColors)
            
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
    
    @StateObject var blendViewModel: BlendViewModel
    @FocusState var isFocused: Bool
    
    @Environment(\.dismiss) var dismiss
    
    init(currentUser: User) {
        _blendViewModel = StateObject(wrappedValue: BlendViewModel(currentUser: currentUser))
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 10) {
                    Text("Fill out the details below to create a blend with your friends!")
                        .font(.body)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("PrimaryText"))
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 0) {
                        // view for event title input
                        BlendTitleView(title: $blendViewModel.title, isFocused: $isFocused, hasTriedSubmitting: $blendViewModel.hasTriedSubmitting, titleError: $blendViewModel.titleError)
                        
                        // view for inviting friends selection
                        EventInviteesView(selectedFriends: $blendViewModel.selectedFriends, showInviteUsersSheet: $blendViewModel.showInviteUsersSheet)
                            .sheet(isPresented: $blendViewModel.showInviteUsersSheet) {
                                AddUsersToBlend(blendViewModel: blendViewModel)
                            }
                            .task {
                                await blendViewModel.fetchFriends()
                            }
                        
                        // view for selecting the colors of the events of invited users
                        Group {
                            if !blendViewModel.selectedFriends.isEmpty {
                                BlendColorsForInvitees(
                                    selectedFriends: $blendViewModel.selectedFriends,
                                    showColorPickerSheet: $blendViewModel.showColorPickerSheet,
                                    colors: $blendViewModel.userColors,
                                    showColorPickerForUserId: $blendViewModel.showingColorPickerForUserId
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        // Drive the transition animation by changes in selectedFriends.count
                        .animation(.easeInOut(duration: 0.3), value: blendViewModel.selectedFriends.count)
                        .sheet(isPresented: $blendViewModel.showColorPickerSheet) {
                            BlendColorPickerSheet(colors: $blendViewModel.userColors, userId: $blendViewModel.showingColorPickerForUserId)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await blendViewModel.createBlend()
                            if blendViewModel.shouldDismiss {
                                dismiss()
                            }
                        }
                    }, label: {
                        Text("Create Blend")
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColors"))
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
            .scrollBounceBehavior(.basedOnSize)
            .defaultScrollAnchor(.top, for: .initialOffset)
            .defaultScrollAnchor(.bottom, for: .sizeChanges)
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                isFocused = false
            }
        }
        .navigationBarBackButtonHidden(false)
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
            Group {
                if blendViewModel.isLoading {
                    FriendsLoadingView()
                        .padding(.horizontal)
                } else if let error = blendViewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color(hex: 0x666666))
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else if blendViewModel.userFriends.isEmpty {
                    Spacer()
                    Text("No friends found. Add your first friend by clicking the Search icon below!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color(hex: 0x666666))
                        .tracking(-0.25)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(filteredUsers, id: \.self.id) { friend in
                            InvitedUserCell(friend: friend, isAvailable: true)
                        }
                    }
                    .padding(.horizontal, 8)
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .task {
            await blendViewModel.fetchFriends()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for friends")
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
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
            
                TextField("Blend Name", text: titleBinding, prompt:
                            Text("Blend Name")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color("SecondaryText"))
                                .tracking(-0.25),
                          axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color("PrimaryText"))
                    .tracking(-0.25)
                    .focused(isFocused)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .onChange(of: title) { _, newValue in
                        guard let newValue = newValue else { return }
                        guard isFocused.wrappedValue == true else { return }
                        guard newValue.contains("\n") else { return }
                        isFocused.wrappedValue = false
                        title = newValue.replacing("\n", with: "")
                    }
                
                Spacer()
                Button(action: {
                    title = nil
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(Color("IconColors"))
                }
                .opacity(title == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.4), value: title)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .stroke(hasTriedSubmitting && title == nil ? Color("ErrorTextColor") : Color("TextFieldBorders"), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 0) {
                    Text("Blend Name")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .fontDesign(.monospaced)
                        .padding(.horizontal, 4)
                        .background(Color("BackgroundColor"))
                        .offset(y: -9)
                        .padding(.leading, 16)
                }
                .opacity(title != nil || isFocused.wrappedValue == true ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue == true || title != nil)
            }

            Text(titleError.isEmpty ? " " : titleError)
                .font(.footnote)
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color("ErrorTextColor"))
                .opacity(titleError.isEmpty ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: titleError.isEmpty)
        }
        .padding(.top, 10)
    }
}

struct BlendColorsForInvitees: View {
    
    @Binding var selectedFriends: [User]
    @Binding var showColorPickerSheet: Bool
    @Binding var colors: [UserMappedBlendColor]
    @Binding var showColorPickerForUserId: String?
    
    var body: some View {
        Group {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(selectedFriends.indices, id: \.self) { index in
                        let user = selectedFriends[index]
                        HStack {
                            InvitedUserRow(user: user)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            
                            Spacer()
                            
                            Button(action: {
                                showColorPickerForUserId = user.id
                                showColorPickerSheet = true
                            }) {
                                if !colors.contains(where: { $0.userId == user.id }) {
                                    Image(systemName: "paintbrush")
                                        .foregroundColor(Color("IconColors"))
                                        .imageScale(.large)
                                } else if let color = colors.first(where: { $0.userId == user.id }) {
                                    HStack(alignment: .center, spacing: 3) {
                                        Image(systemName: "paintbrush")
                                            .foregroundColor(Color("IconColors"))
                                            .imageScale(.large)
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: Int(color.color, radix: 16)!))
                                            .frame(maxWidth: 55, maxHeight: 25)
                                    }
                                } else {
                                    HStack(alignment: .center, spacing: 3) {
                                        Image(systemName: "paintbrush")
                                            .foregroundColor(Color("IconColors"))
                                            .imageScale(.large)
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.clear)
                                            .frame(maxWidth: 55, maxHeight: 25)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("TextFieldBorders"), lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 0) {
                        Text("Blend Colors")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .fontDesign(.monospaced)
                            .padding(.horizontal, 4)
                            .background(Color("BackgroundColor"))
                            .offset(y: -9)
                            .padding(.leading, 16)
                    }
                    .opacity(!selectedFriends.isEmpty ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedFriends.isEmpty)
                }

//                Text(titleError.isEmpty ? " " : titleError)
//                    .font(.footnote)
//                    .padding(.leading)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundStyle(.red)
//                    .opacity(titleError.isEmpty ? 0 : 1)
//                    .animation(.easeInOut(duration: 0.2), value: titleError.isEmpty)
            }
            .padding(.top, 10)
        }
    }
}

struct BlendColorPickerSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    let palettes: [ColorPalette] = [ColorPalette.pastel, ColorPalette.rustic, ColorPalette.foresty, ColorPalette.monochrome]
    @State var selectedColor: Color = Color.clear
    @Binding var colors: [UserMappedBlendColor]
    @Binding var userId: String?
    @State var sheetPresentationState: PresentationDetent = .medium
    
    let singleRowColumns = Array(repeating: GridItem(.fixed(44)), count: ColorPalette.pastel.colors.count)
    let multiRowColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(palettes, id: \.name) { palette in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(palette.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .foregroundStyle(Color("PrimaryText"))
                            .padding(.leading)
                        
                        ScrollView(sheetPresentationState == .large ? .vertical : .horizontal, showsIndicators: false) {
                            LazyVGrid(columns: sheetPresentationState == .large ? multiRowColumns : singleRowColumns, alignment: .leading) {
                                ForEach(palette.colors, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                        guard let userId = userId else { return }
                                        if colors.contains(where: { $0.userId == userId }) {
                                            let index = colors.firstIndex(where: { $0.userId == userId })!
                                            // If UserMappedBlendColor.color is `let`, replace the element:
                                            if let hex = color.toHex() {
                                                colors[index] = UserMappedBlendColor(userId: userId, color: hex)
                                            }
                                        } else {
                                            if let hex = color.toHex() {
                                                colors.append(UserMappedBlendColor(userId: userId, color: hex))
                                            }
                                        }
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
                            .padding()
                        }
                        .animation(.easeInOut(duration: 0.2), value: sheetPresentationState)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
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

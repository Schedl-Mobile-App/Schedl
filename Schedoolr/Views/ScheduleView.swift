
import SwiftUI
import UIKit

class ScrollOffsetManager: ObservableObject {
    @Published var horizontalOffset: CGFloat = 0
    @Published var verticalOffset: CGFloat = -10
}

class ViewController: UIViewController, UIScrollViewDelegate {
    
    private let scrollView: UIScrollView = {
       let sv = UIScrollView()
        sv.backgroundColor = .systemBackground
        
        sv.alwaysBounceHorizontal = false
        // Show scroll indicators
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = true
        // slows the rate of scrolling
        sv.decelerationRate = .fast
        // disables multi-direction scrolling
        sv.isDirectionalLockEnabled = true
        
        return sv
    }()
    
    private let contentView: UIView
    private let offsetManager: ScrollOffsetManager
    private let dayWidth: CGFloat
    private let hourHeight: CGFloat
    private var isScrolling: Binding<Bool>
    
    init(contentView: UIView, offsetManager: ScrollOffsetManager, dayWidth: CGFloat, hourHeight: CGFloat, isScrolling: Binding<Bool>) {
        self.contentView = contentView
        self.offsetManager = offsetManager
        self.dayWidth = dayWidth
        self.hourHeight = hourHeight
        self.isScrolling = isScrolling
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        self.setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToPosition()
    }
    
    func scrollToPosition() {
        let hour = Calendar.current.component(.hour, from: Date())
        let offsetY = hour <= 13 ? hour * Int(hourHeight) : 13 * Int(hourHeight)

        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.offsetManager.horizontalOffset = scrollView.contentOffset.x
            self.offsetManager.verticalOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling.wrappedValue = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let itemWidth = dayWidth  // Width of each day column
        
        // Calculate the target page based on current scroll position
        let targetXPosition = targetContentOffset.pointee.x
        let nearestPage = round(targetXPosition / itemWidth)
        
        // Calculate the exact x position where the scroll should stop
        let snapToX = nearestPage * itemWidth
        
        // Update the target content offset
        targetContentOffset.pointee = CGPoint(x: snapToX, y: targetContentOffset.pointee.y)
        
        self.isScrolling.wrappedValue = false
    }

    private func setupUI() {
        self.view.backgroundColor = .systemBlue
        
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        self.scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let hConst = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)
        
        let wConst = contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        wConst.isActive = true
        wConst.priority = UILayoutPriority(50)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo:
                self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor)
        ])
    }
}

struct CustomScrollView<Content: View>: UIViewControllerRepresentable {
    
    let content: Content
    @ObservedObject var offsetManager: ScrollOffsetManager
    let dayWidth: CGFloat
    let hourHeight: CGFloat
    @Binding var isScrolling: Bool
    
    init(offsetManager: ScrollOffsetManager, dayWidth: CGFloat, hourHeight: CGFloat, isScrolling: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.offsetManager = offsetManager
        self.dayWidth = dayWidth
        self.hourHeight = hourHeight
        self._isScrolling = isScrolling
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        // Convert SwiftUI view to UIKit view
        let hostingController = UIHostingController(rootView: content)
        return ViewController(contentView: hostingController.view, offsetManager: offsetManager, dayWidth: dayWidth, hourHeight: hourHeight, isScrolling: $isScrolling)
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

struct ScheduleView: View {
    @StateObject var offsetManager: ScrollOffsetManager = ScrollOffsetManager()
    @EnvironmentObject var authService: AuthService
    @StateObject var scheduleViewModel: ScheduleViewModel = ScheduleViewModel()
    private let hourHeight: CGFloat = 80
    private let dayWidth: CGFloat = 150
    private let timeColumnWidth: CGFloat = 50
    private let currentMonth: Int = Calendar.current.component(.month, from: Date())
    @State var isScrolling = false
    private let months: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    @State private var isCreatingEvent = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                ScheduleHeader()
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: timeColumnWidth)
                    
                    GeometryReader { geometry in
                        ScrollView(.horizontal, showsIndicators: false) {
                            WeekRow(dayWidth: dayWidth)
                        }
                        .scrollDisabled(true)
                        .offset(x: -offsetManager.horizontalOffset)
                        .frame(width: dayWidth*7)
                        .clipped()  // This will clip/hide content that scrolls outside the frame
                    }
                }
                .background(Color(.systemBackground))
                .frame(height: 40)
                
                HStack(spacing: 0) {
                    GeometryReader { geometry in
                        ScrollView(.vertical, showsIndicators: false) {
                            TimeColumn(hourHeight: hourHeight)
                        }
                        .scrollDisabled(true)
                        .offset(y: -offsetManager.verticalOffset)
                        .frame(height: hourHeight*24)
                        .clipped()
                    }
                    .frame(width: timeColumnWidth)
                    
                    // Custom UIKit ScrollView embedded in SwiftUI
                    CustomScrollView(offsetManager: offsetManager, dayWidth: dayWidth, hourHeight: hourHeight, isScrolling: $isScrolling, content: {
                        EventsGrid(hourHeight: hourHeight, dayWidth: dayWidth)
                            .frame(width: dayWidth * 7)
                            .fixedSize(horizontal: true, vertical: false)
                    })
                    .frame(maxWidth: UIScreen.main.bounds.width)
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 1, alignment: .leading)
            
            NavigationLink(destination: CreateEventView()
                .environmentObject(scheduleViewModel)
            ) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundColor(Color("FormButtons"))
                    .font(.system(size: 25))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(30)
            .opacity(isScrolling ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: isScrolling)
            
            if scheduleViewModel.sideBarState {
                SideBar()
            }
        }
        .environmentObject(scheduleViewModel)
        .onAppear {
            Task {
                if let user = authService.currentUser {
                    await scheduleViewModel.fetchSchedule(id: user.schedules[0])
                }
            }
        }
        .animation(.easeInOut, value: scheduleViewModel.sideBarState)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SideBar: View {
    
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    @State var showMySchedules = false
    @State var showFriendsSchedules = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack() {
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        Spacer()
                        Button(action: {
                            scheduleViewModel.toggleSideBar()
                        }) {
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundStyle(.clear)
                                .overlay {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(Color.primary)
                                        .font(.system(size: 24))
                                }
                        }
                        .frame(width: 25, height: 50, alignment: .trailing)
                        .padding(.horizontal)
                        .padding(.top, 65)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center) {
                            Text(scheduleViewModel.schedule?.title ?? "David's Schedule")
                                .font(.system(size: 20, design: .monospaced))
                                .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(alignment: .center, spacing: 10) {
                            Text("My Schedules")
                                .font(.system(size: 20, design: .monospaced))
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(showMySchedules ? 180 : 0))
                                .animation(.easeInOut, value: showMySchedules)
                        }
                        .padding()
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .border(width: 1, edges: [.top], color: Color.primary)
                        .onTapGesture {
                            showMySchedules.toggle()
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                            Text("Friends Schedules")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20, design: .monospaced))
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(showFriendsSchedules ? 180 : 0))
                                .animation(.easeInOut, value: showFriendsSchedules)
                        }
                        .padding()
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .border(width: 1, edges: [.top, .bottom], color: Color.primary)
                        .onTapGesture {
                            showFriendsSchedules.toggle()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(edges: .all)
                .background(Color("DarkBackground"))
            }
            .foregroundStyle(Color.primary)
            .transition(.move(edge: .leading))
            .frame(maxWidth: UIScreen.main.bounds.width * 0.70, maxHeight: .infinity, alignment: .top)
        }
        .zIndex(1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
    }
}

struct WeekRow: View {
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let dayWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek.indices, id: \.self) { index in
                Text(daysOfWeek[index])
                    .font(.caption)
                    .bold()
                    .frame(width: dayWidth, height: 40)
                    .border(width: 1, edges: [.leading], color: .gray.opacity(0.2))
            }
        }
    }
}

struct ScheduleHeader: View {
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(Color.primary)
                .font(.system(size: 24))
                .onTapGesture {
                    scheduleViewModel.toggleSideBar()
                }
            
            HStack (spacing: 0) {
                Text(monthText)
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                Text(yearText)
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 24, weight: .bold, design: .serif))
            }
            
            Spacer()
            
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundStyle(Color.primary)
                .font(.system(size: 24))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }
    
    private var yearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedDate)
    }
}

struct TimeColumn: View {
    let hourHeight: CGFloat
    let hourList: [String] = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<23) { hour in
                Text("\(hourList[hour%12]) \(hour < 11 ? "AM" : "PM")")
                    .font(.caption)
                    .frame(height: hourHeight, alignment: .bottom)
                    .frame(maxWidth: .infinity)
                    .offset(y: 7)
            }
        }
    }
}

struct EventsGrid: View {
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    let hourHeight: CGFloat
    let dayWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<7) { dayIndex in
                VStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: dayWidth, height: hourHeight)
                            .border(Color.gray.opacity(0.2), width: 0.5)
                    }
                }
                .overlay(
                    eventsForDay(dayIndex: dayIndex)
                )
            }
        }
    }
    
    @ViewBuilder
    private func eventsForDay(dayIndex: Int) -> some View {
        if let events = scheduleViewModel.events {
            ForEach(events.filter { event in
                let calendar = Calendar.current
                let weekday = calendar.component(.weekday, from: event.eventDate) - 1
                return weekday == dayIndex
            }) { event in
                let position = scheduleViewModel.calculateEventPosition(event: event, hourHeight: hourHeight)
                EventCell(event: event)
                    .frame(width: dayWidth - 4)
                    .frame(height: position.height)
                    .position(x: dayWidth/2, y: position.offset + position.height/2)
            }
        }
    }
}

struct EventCell: View {
    let event: Event
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel
    
    var body: some View {
        NavigationLink(destination: EventDetailsView(event: event)
            .environmentObject(scheduleViewModel)
        ) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.blue.opacity(0.2))
                .overlay(
                    Text(event.title)
                        .font(.caption)
                        .padding(4)
                        .lineLimit(1)
                )
        }
        .onTapGesture {
            scheduleViewModel.selectedEvent = event
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(AuthService())
}

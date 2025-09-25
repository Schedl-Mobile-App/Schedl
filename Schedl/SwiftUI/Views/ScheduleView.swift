
import SwiftUI
import UIKit

// allows for our View Controller to be embedded within a SwiftUI view
struct ScheduleView: UIViewControllerRepresentable {
    
    @StateObject var scheduleViewModel: ScheduleViewModel
    @EnvironmentObject var tabBarState: TabBarState
    var onShowEventDetails: (RecurringEvents, User, String) -> Void
    
    init(currentUser: User, onShowEventDetails: @escaping (RecurringEvents, User, String) -> Void) {
        _scheduleViewModel = StateObject(wrappedValue: ScheduleViewModel(currentUser: currentUser))
        self.onShowEventDetails = onShowEventDetails
    }
    
    class Coordinator {
        var scheduleViewModel: ScheduleViewModel
        var tabBarState: TabBarState
        var onShowEventDetails: (RecurringEvents, User, String) -> Void
        
        init(scheduleViewModel: ScheduleViewModel, tabBarState: TabBarState, onShowEventDetails: @escaping (RecurringEvents, User, String) -> Void) {
            self.scheduleViewModel = scheduleViewModel
            self.tabBarState = tabBarState
            self.onShowEventDetails = onShowEventDetails
        }
        
        // This is the function the UIViewController will call
        func showEventDetails(event: RecurringEvents, currentUser: User, scheduleId: String) {
            // When called, it executes the closure, sending the data up to SwiftUI
            onShowEventDetails(event, currentUser, scheduleId)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scheduleViewModel: scheduleViewModel, tabBarState: tabBarState, onShowEventDetails: onShowEventDetails)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let scheduleView = ScheduleViewController()
        
        // anytime that a specific action occurs, particularly in the
        // schedule view model object, our view controller will report
        // this action to our coordinator here
        scheduleView.coordinator = context.coordinator
        
        let navController = UINavigationController(rootViewController: scheduleView)
//        navController.view.backgroundColor = UIColor(Color(hex: 0xf7f4f2))
//        navController.navigationController?.navigationBar.barTintColor = .yellow
        navController.hidesBottomBarWhenPushed = true
        if #available(iOS 26.0, *) {
            navController.tabBarController?.tabBarMinimizeBehavior = .onScrollDown
        } else {
            // Fallback on earlier versions
        }
        
        return scheduleView
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

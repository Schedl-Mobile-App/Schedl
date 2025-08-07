
import SwiftUI
import UIKit

// allows for our View Controller to be embedded within a SwiftUI view
struct ScheduleView: UIViewControllerRepresentable {
    
    @StateObject var scheduleViewModel: ScheduleViewModel
    @EnvironmentObject var tabBarState: TabBarState
    
    init(currentUser: User) {
        _scheduleViewModel = StateObject(wrappedValue: ScheduleViewModel(currentUser: currentUser))
    }
    
    class Coordinator {
        var scheduleViewModel: ScheduleViewModel
        var tabBarState: TabBarState
        
        init(scheduleViewModel: ScheduleViewModel, tabBarState: TabBarState) {
            self.scheduleViewModel = scheduleViewModel
            self.tabBarState = tabBarState
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scheduleViewModel: scheduleViewModel, tabBarState: tabBarState)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let scheduleView = ScheduleViewController()
        
        // anytime that a specific action occurs, particularly in the
        // schedule view model object, our view controller will report
        // this action to our coordinator here
        scheduleView.coordinator = context.coordinator
        
        let navController = UINavigationController(rootViewController: scheduleView)
        
        navController.setNavigationBarHidden(true, animated: false)
        navController.hidesBottomBarWhenPushed = true
        
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

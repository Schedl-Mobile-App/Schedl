
import SwiftUI
import UIKit

// allows for our View Controller to be embedded within a SwiftUI view
struct ScheduleView: UIViewControllerRepresentable {
    
    @StateObject var scheduleViewModel: ScheduleViewModel
    @Environment(\.router) var coordinator: Router
    
    init(currentUser: User) {
        _scheduleViewModel = StateObject(wrappedValue: ScheduleViewModel(currentUser: currentUser))
    }
    
    class Coordinator {
        var scheduleViewModel: ScheduleViewModel
        var coordinator: Router
        
        init(scheduleViewModel: ScheduleViewModel, coordinator: Router) {
            self.scheduleViewModel = scheduleViewModel
            self.coordinator = coordinator
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scheduleViewModel: scheduleViewModel, coordinator: coordinator)
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

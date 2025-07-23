
import SwiftUI
import UIKit

// allows for our View Controller to be embedded within a SwiftUI view
struct ScheduleView: UIViewControllerRepresentable {
    
    @StateObject var scheduleViewModel: ScheduleViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init(currentUser: User) {
        _scheduleViewModel = StateObject(wrappedValue: ScheduleViewModel(currentUser: currentUser))
    }
    
    class Coordinator {
        var scheduleViewModel: ScheduleViewModel
        var authViewModel: AuthViewModel
        
        init(scheduleViewModel: ScheduleViewModel, authViewModel: AuthViewModel) {
            self.scheduleViewModel = scheduleViewModel
            self.authViewModel = authViewModel
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scheduleViewModel: scheduleViewModel, authViewModel: authViewModel)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let scheduleView = ScheduleViewController()
        
        // anytime that a specific action occurs, particularly in the
        // schedule view model object, our view controller will report
        // this action to our coordinator here
        scheduleView.coordinator = context.coordinator
        
        let navController = UINavigationController(rootViewController: scheduleView)
        
        navController.navigationBar.isTranslucent = false
        navController.setNavigationBarHidden(true, animated: false)
        navController.hidesBottomBarWhenPushed = true
        navController.toolbar.isTranslucent = true
        
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

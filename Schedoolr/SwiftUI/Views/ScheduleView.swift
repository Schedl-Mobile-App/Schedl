
import SwiftUI
import UIKit

// allows for our View Controller to be embedded within a SwiftUI view
struct ScheduleView: UIViewControllerRepresentable {
    
    @StateObject var viewModel = ScheduleViewModel()
    @EnvironmentObject var authService: AuthService
    
    class Coordinator {
        var viewModel: ScheduleViewModel
        var authService: AuthService
        
        init(viewModel: ScheduleViewModel, authService: AuthService) {
            self.viewModel = viewModel
            self.authService = authService
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, authService: authService)
    }
    
    func makeUIViewController(context: Context) -> ScheduleViewController {
        let scheduleView = ScheduleViewController()
//        scheduleView.edgesForExtendedLayout = .all
//        
//        // Make the view controller properly fill its container
//        scheduleView.view.insetsLayoutMarginsFromSafeArea = false
        
        // anytime that a specific action occurs, particularly in the
        // schedule view model object, our view controller will report
        // this action to our coordinator here
        scheduleView.coordinator = context.coordinator
        
        return scheduleView
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

#Preview {
    ScheduleView()
        .environmentObject(AuthService())
}

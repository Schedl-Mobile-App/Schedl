
import SwiftUI

// allows for our View Controller to be embedded within a SwiftUI view
struct ScheduleView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let scheduleView = ScheduleViewController()
        return scheduleView
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

#Preview {
    ScheduleView()
        .environmentObject(AuthService())
}

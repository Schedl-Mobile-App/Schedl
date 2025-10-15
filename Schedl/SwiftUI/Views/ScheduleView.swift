import SwiftUI
import UIKit

protocol VCCoordinatorProtocol {
    var coordinator: CalendarYearView.Coordinator? { get set }
}

struct CalendarYearView: UIViewControllerRepresentable {
    
    @StateObject var vm: ScheduleViewModel
//    @Environment(\.router) var router: Router
    var centerYear: Date
    
    init(currentUser: User, centerYear: Date) {
        _vm = StateObject(wrappedValue: ScheduleViewModel(currentUser: currentUser))
        self.centerYear = centerYear
    }
    
    class Coordinator {
        var vm: ScheduleViewModel
//        var router: Router
        
        init(vm: ScheduleViewModel, /*router: Router*/) {
            self.vm = vm
//            self.router = router
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(vm: vm, /*router: router*/)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let yearView = YearViewController(centerYear: centerYear)
        yearView.restorationIdentifier = "YearViewController"
        
        // anytime that a specific action occurs, particularly in the
        // schedule view model object, our view controller will report
        // this action to our coordinator here
        yearView.coordinator = context.coordinator
        
        let navController = UINavigationController(rootViewController: yearView)
        navController.restorationIdentifier = "ScheduleNavigationController"
        
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if var topVc = uiViewController.topViewController as? VCCoordinatorProtocol {
            topVc.coordinator = context.coordinator
        }
    }
}

//struct CalendarMonthView: UIViewControllerRepresentable {
//    
//    @ObservedObject var vm: ScheduleViewModel
//    @Environment(\.router) var router: Router
//    var centerMonth: Date
//    
//    init(vm: ScheduleViewModel, centerMonth: Date) {
//        _vm = ObservedObject(initialValue: vm)
//        self.centerMonth = centerMonth
//    }
//    
//    class Coordinator {
//        var vm: ScheduleViewModel
//        var router: Router
//        
//        init(vm: ScheduleViewModel, router: Router) {
//            self.vm = vm
//            self.router = router
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(vm: vm, router: router)
//    }
//        
//    func makeUIViewController(context: Context) -> UIViewController {
//        let monthView = MonthViewController(centerMonth: centerMonth)
//        
//        // anytime that a specific action occurs, particularly in the
//        // schedule view model object, our view controller will report
//        // this action to our coordinator here
//        monthView.coordinator = context.coordinator
//        
//        return monthView
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        
//    }
//}
//
//struct CalendarWeekView: UIViewControllerRepresentable {
//    
//    @ObservedObject var vm: ScheduleViewModel
//    @Environment(\.router) var router: Router
//    var centerDay: Date
//    
//    init(vm: ScheduleViewModel, centerDay: Date = Self.createCenterDay()) {
//        _vm = ObservedObject(initialValue: vm)
//        self.centerDay = centerDay
//    }
//    
//    class Coordinator {
//        var vm: ScheduleViewModel
//        var router: Router
//        
//        init(vm: ScheduleViewModel, router: Router) {
//            self.vm = vm
//            self.router = router
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(vm: vm, router: router)
//    }
//    
//    static func createCenterDay() -> Date {
//        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//        return Calendar.current.date(from: dateComponents)!
//    }
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let weekView = WeekViewController(centerDay: centerDay)
//        
//        // anytime that a specific action occurs, particularly in the
//        // schedule view model object, our view controller will report
//        // this action to our coordinator here
//        weekView.coordinator = context.coordinator
//        
//        return weekView
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        
//    }
//}
//

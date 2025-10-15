////
////  SchedulesCoordinator.swift
////  Schedl
////
////  Created by David Medina on 9/25/25.
////
//
//import SwiftUI
//
//@Observable
//class SchedulesCoordinator: Router {
//    var path = NavigationPath()
//    var sheet: SheetDestination?
//    var cover: CoverDestination?
//}
//
//struct SchedulesCoordinatorView: View {
//    
//    @Environment(\.tabBar) var tabBar: TabBarViewModel
//    @State private var coordinator = SchedulesCoordinator()
//    
//    @StateObject private var vm: ScheduleViewModel
//    @State private var searchText = ""
//    
//    @FocusState private var isFocused: Bool
//    
//    init(currentUser: User) {
//        _vm = StateObject(wrappedValue: ScheduleViewModel(currentUser: currentUser))
//    }
//    
//    var body: some View {
//        ZStack {
//            NavigationStack(path: $coordinator.path) {
//                PageDestination.calendarYearView(vm: vm, centerYear: createCenterYear())
////                    .ignoresSafeArea(edges: [.top, .bottom])
//                    .navigationDestination(for: PageDestination.self) { destination in
//                        if destination.shouldHideTabbar {
//                            tabBar.isTabBarHidden = true
//                        } else {
//                            tabBar.isTabBarHidden = false
//                        }
//                        
//                         return destination
//                    }
//                    .sheet(item: $coordinator.sheet) { $0 }
//                    .fullScreenCover(item: $coordinator.cover) { $0 }
////                    .task {
////                        await vm.fetchSchedule()
////                    }
//            }
//            .toolbar(tabBar.isTabBarHidden || vm.showSearchView ? .hidden : .visible, for: .tabBar)
//            .environment(\.router, coordinator)
//            
//            GeometryReader { geometry in
//                CustomSearchView(showSearchView: $vm.showSearchView, isFocused: $isFocused, scheduleId: vm.selectedSchedule?.id ?? "", events: vm.scheduleEvents)
//                    .offset(y: vm.showSearchView ? 0 : -geometry.size.height)
//                    .opacity(vm.showSearchView ? 1 : 0)
//            }
//            .ignoresSafeArea()
//        }
//        .onChange(of: vm.showSearchView) { _, newValue in
//            isFocused = newValue
//        }
//    }
//    
//    func createCenterYear() -> Date {
//        let yearComponent = Calendar.current.dateComponents([.year], from: Date())
//        return Calendar.current.date(from: yearComponent)!
//    }
//}
//
//struct ScheduleViewModifier: ViewModifier {
//    @State private var isChevronExpanded = false
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.colorScheme) var colorScheme
//    
//    @ObservedObject var vm: ScheduleViewModel
//        
//    func body(content: Content) -> some View {
//        if #available(iOS 26.0, *) {
//            content
//                .toolbar {
////                    ToolbarItem(placement: .topBarLeading) {
////                        Menu {
////                            Menu("Your Schedules") {
////                                ForEach(vm.userSchedules, id: \.id) { schedule in
////                                    Button(action: {
////                                        Task {
////                                            dismiss()
////                                            await vm.fetchNewSchedule(id: schedule.id)
////                                        }
////                                    }, label: {
////                                        Text(schedule.title)
////                                    })
////                                }
////                            }
////                            
////                            Menu("Your Blends") {
////                                ForEach(vm.userBlends, id: \.id) { blend in
////                                    Button(action: {
////                                        Task {
////                                            dismiss()
////                                            await vm.fetchBlendSchedule(id: blend.id)
////                                        }
////                                    }, label: {
////                                        Text(blend.title)
////                                    })
////                                }
////                            }
////                        } label: {
////                            if let schedule = vm.selectedSchedule {
////                                Text(schedule.title)
////                                    .font(.title2)
////                                    .fontWeight(.bold)
////                                    .foregroundStyle(Color("NavItemsColors"))
////                                    .fixedSize(horizontal: true, vertical: false)
////                                    .padding(.horizontal, 5)
////                            } else if let blend = vm.selectedBlend {
////                                Text(blend.title)
////                                    .font(.title2)
////                                    .fontWeight(.bold)
////                                    .foregroundStyle(Color("NavItemsColors"))
////                                    .fixedSize(horizontal: true, vertical: false)
////                                    .padding(.horizontal, 5)
////                            }
////                        }
////                    }
//                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: {
//                            withAnimation(.easeOut(duration: 0.1)) {
//                                vm.showSearchView = true
//                            }
//                        }, label: {
//                            Image(systemName: "magnifyingglass")
//                                .font(.system(size: 18))
//                                .fontWeight(.semibold)
//                                .foregroundStyle(Color("NavItemsColors"))
//                        })
//                    }
//                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Menu {
//                            ForEach(CalendarType.allCases, id: \.self) { type in
//                                Button(action: {
//                                    dismiss()
//                                    
//                                    if vm.calendarViewType != type {
//                                        vm.calendarViewType = type
//                                    }
//                                }, label: {
//                                    Label(type.title, systemImage: type.symbolName)
//                                })
//                            }
//                        } label: {
//                            Image(systemName: "ellipsis")
//                                .font(.system(size: 18))
//                                .fontWeight(.semibold)
//                                .foregroundStyle(Color("NavItemsColors"))
//                        }
//                    }
//                }
//        } else {
//            content
//                .toolbar {
//                    ToolbarItem(placement: .bottomBar) {
//                        HStack {
//                            Button(action: {
//                                vm.scrollToCurrentPosition = true
//                            }, label: {
//                                Image(systemName: vm.scrollState == .scrollingUp ? "arrow.down" : "arrow.up")
//                                    .contentTransition(.symbolEffect(.replace))
//                                    .font(.system(size: 18, weight: .medium))
//                            })
//                            Spacer()
//                            Text("David's Schedule")
//                            Spacer()
//                        }
//                        .padding(.horizontal)
//                    }
//                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: {
//                            withAnimation(.easeOut(duration: 0.1)) {
//                                vm.showSearchView = true
//                            }
//                        }, label: {
//                            Image(systemName: "magnifyingglass")
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundStyle(Color("NavItemsColors"))
//                        })
//                    }
//                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Menu {
//                            ForEach(CalendarType.allCases, id: \.self) { type in
//                                Button(action: {
//                                    dismiss()
//                                    
//                                    if vm.calendarViewType != type {
//                                        vm.calendarViewType = type
//                                    }
//                                }, label: {
//                                    Label(type.title, systemImage: type.symbolName)
//                                })
//                            }
//                        } label: {
//                            Image(systemName: "ellipsis")
//                                .font(.system(size: 18))
//                                .fontWeight(.semibold)
//                                .foregroundStyle(Color("NavItemsColors"))
//                        }
//                    }
//                }
//        }
//    }
//}
//
//enum CalendarType: CaseIterable {
//    case day
//    case week
//    case month
//    
//    var title: String {
//        switch self {
//        case .day:
//            return "Day"
//        case .week:
//            return "Week"
//        case .month:
//            return "Month"
//        }
//    }
//    
//    var symbolName: String {
//        switch self {
//        case .day:
//            return "sun.max"
//        case .week:
//            return "circle.hexagongrid"
//        case .month:
//            return "calendar"
//        }
//    }
//}
//

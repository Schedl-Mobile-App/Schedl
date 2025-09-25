//
//  SchedulesCoordinator.swift
//  Schedl
//
//  Created by David Medina on 9/25/25.
//

import SwiftUI

@Observable
class SchedulesCoordinator: Router {
    var path = NavigationPath()
    var sheet: SheetDestination?
    var cover: CoverDestination?
}

struct SchedulesCoordinatorView: View {
    
    @State private var coordinator = SchedulesCoordinator()
    var currentUser: User
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            PageDestination.schedule(currentUser: currentUser)
                .ignoresSafeArea(edges: [.top, .bottom])
                .navigationDestination(for: PageDestination.self) { $0 }
                .sheet(item: $coordinator.sheet) { $0 }
                .fullScreenCover(item: $coordinator.cover) { $0 }
                .modifier(ScheduleViewModifier())
        }
        .environment(\.router, coordinator)
    }
}

struct ScheduleViewModifier: ViewModifier {
    @State private var isChevronExpanded = false
        
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("David's Schedule")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("NavItemsColors"))
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "ellipsis")
                        })
                    }
                }
        } else {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isChevronExpanded.toggle()
                            }
                        }, label: {
                            HStack {
                                Text("David's Schedule")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("NavItemsColors"))
                                    .fixedSize(horizontal: true, vertical: false)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .rotationEffect(.degrees(isChevronExpanded ? 180 : 0))
                            }
                        })
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "ellipsis")
                        })
                    }
                }
        }
    }
}


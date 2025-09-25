//
//  FriendsLoadingView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct FriendsLoadingView: View {
    
    @State var showSearchTitle: Bool
    
    init(showSearchTitle: Bool = false) {
        _showSearchTitle = State(initialValue: showSearchTitle)
    }
    
    var body: some View {
        List {
            if showSearchTitle {
                if #available(iOS 26.0, *) {
                    Section(content: {
                        ForEach(1..<10) { _ in
                            LoadingFriendCell()
                        }
                    }, header: {
                        HStack {
                            Text("Search")
                                .font(.headline)
                                .fontWeight(.bold)
                                .fontDesign(.monospaced)
                                .foregroundStyle(Color("NavItemsColors"))
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    })
                    .listSectionSeparator(.hidden, edges: .top)
                    .listSectionMargins(.top, -12.5)
                } else {
                    Section(content: {
                        ForEach(1..<10) { _ in
                            LoadingFriendCell()
                        }
                    }, header: {
                        EmptyView()
                    })
                    .listSectionSeparator(.hidden, edges: .top)
                }
                        
            } else {
                Section(content: {
                    ForEach(1..<10) { _ in
                        LoadingFriendCell()
                    }
                }, header: {
                    EmptyView()
                })
                .listSectionSeparator(.hidden, edges: .top)
            }
        }
        .listStyle(.plain)
    }
}

struct LoadingFriendCell: View {
    
    var body: some View {
        HStack(spacing: 15) {
            ShimmerEffectBox()
                .cornerRadius(54)
                .frame(width: 55, height: 55)
            
            VStack(alignment: .leading) {
                ShimmerEffectBox()
                    .cornerRadius(15)
                    .frame(width: 150, height: 12.5)
                ShimmerEffectBox()
                    .cornerRadius(15)
                    .frame(width: 90, height: 10)
                ShimmerEffectBox()
                    .cornerRadius(15)
                    .frame(width: 150, height: 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    FriendsLoadingView()
}

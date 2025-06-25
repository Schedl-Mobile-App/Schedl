//
//  FriendsLoadingView.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct FriendsLoadingView: View {
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(1..<10) { _ in
                    HStack(spacing: 15) {
                        ShimmerEffectBox()
                            .cornerRadius(54)
                            .frame(width: 55, height: 55)
                        
                        VStack(alignment: .leading) {
                            ShimmerEffectBox()
                                .cornerRadius(15)
                                .frame(width: 150, height: 15)
                            ShimmerEffectBox()
                                .cornerRadius(15)
                                .frame(width: 90, height: 10)
                            ShimmerEffectBox()
                                .cornerRadius(15)
                                .frame(width: 150, height: 10)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

#Preview {
    FriendsLoadingView()
}

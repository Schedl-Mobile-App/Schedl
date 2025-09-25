//
//  ProfileInformatics.swift
//  Schedl
//
//  Created by David Medina on 6/19/25.
//

import SwiftUI

struct ProfileInformatics: View {
    
    let friendsCount: Int
    let eventsCount: Int
    let postsCount: Int
    
    var body: some View {
        
        HStack(spacing: 20) {
            NavigationLink(value: ProfileDestinations.friendsView, label: {
                VStack(alignment: .center, spacing: 6) {
                    Text("\(friendsCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(Color("PrimaryText"))
                    Text("Friends")
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("SecondaryText"))
                        .tracking(-0.25)
                        .fixedSize()
                }
                .frame(minWidth: 60)
            })
            
            Divider()
                .frame(width: 0.5, height: 40)
            
            
            VStack(alignment: .center, spacing: 6) {
                Text("\(eventsCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(Color("PrimaryText"))
                Text("Events")
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("SecondaryText"))
                    .tracking(-0.25)
                    .fixedSize()
            }
            .frame(minWidth: 60)
            
            Divider()
                .frame(width: 0.5, height: 40)
            
            
            VStack(alignment: .center, spacing: 6) {
                Text("\(postsCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(Color("PrimaryText"))
                Text("Posts")
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("SecondaryText"))
                    .tracking(-0.25)
                    .fixedSize()
            }
        }
        .padding()
        .frame(minWidth: 60)
        .modifier(ProfileInformaticsModifier())
    }
}

struct ProfileInformaticsModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 15))
        } else {
            content
                .background(Color("SectionalColors"), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

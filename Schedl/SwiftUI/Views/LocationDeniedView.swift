//
//  LocationDeniedView.swift
//  Schedoolr
//
//  Created by David Medina on 5/24/25.
//

import SwiftUI

struct LocationDeniedView: View {
    
    var body: some View {
        ContentUnavailableView(label: {
            Label {
                Text("Location Services")
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
            } icon: {
                Image("AppIconWithName")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 5)
                    .padding(.bottom)
            }
        }, description: {
            Text("""
                1. Tab the button below and go to "Privacy and Security."
                2. Tap on "Location Services."
                3. Locate the "My Trips" app and tap on it.
                4. Change the setting to "While Using the App."
                """)
            .padding(.top)
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
            .font(.system(size: 20, weight: .medium, design: .rounded))
        }, actions: {
            Button(action: {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            }) {
                Text("Open Settings")
                    .foregroundColor(Color(hex: 0xf7f4f2))
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .tracking(0.01)
            }
            .padding(15)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: 0x47a2be))
            }
            
        })
        .background(Color(hex: 0xf7f4f2))
    }
}

#Preview {
    LocationDeniedView()
}

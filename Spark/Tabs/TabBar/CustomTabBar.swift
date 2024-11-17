//
//  CustomTabBar.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI

enum tabTracker: Int {
    case profile = 0
    case friendsAvailability = 1 // Updated case name
    case currentEvents = 2
}

struct CustomTabBar: View {
    @Binding var tabSelected: tabTracker
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                tabSelected = .profile
                selectedTab = .profile
            } label: {
                tabBarButtons(buttonText: "Profile", imageName: "person", isActive: tabSelected == .profile)
            }
            .tint(Color(hue: 0.725, saturation: 0.5, brightness: 0.912))
            
            Button {
                tabSelected = .friendsAvailability // Updated enum case
                selectedTab = .friendsAvailability // Updated to match `Tab` enum
            } label: {
                GeometryReader { geo in
                    if selectedTab == .friendsAvailability { // Updated condition
                        Rectangle()
                            .foregroundColor(Color(hue: 0.725, saturation: 0.5, brightness: 0.912))
                            .frame(width: geo.size.width / 2, height: 4)
                            .padding(.leading, geo.size.width / 4)
                    }
                    VStack(alignment: .center, spacing: 4) {
                        Image(systemName: "person.2.fill") // Updated icon for Friends Availability
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Text("Friends Availability")
                            .font(Font.custom("LexendDeca-Regular", size: 10))
                    }
                    .padding(.leading, 40)
                    .padding(.top, 15)
                }
            }
            .tint(Color(hue: 0.725, saturation: 0.5, brightness: 0.912))
            
            Button {
                tabSelected = .currentEvents
                selectedTab = .currentEvents
            } label: {
                tabBarButtons(buttonText: "Current Events", imageName: "calendar", isActive: tabSelected == .currentEvents)
            }
            .tint(Color(hue: 0.725, saturation: 0.5, brightness: 0.912))
        }
        .frame(height: 82)
    }
}

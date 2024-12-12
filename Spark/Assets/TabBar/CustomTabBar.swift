//
//  CustomTabBar.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI

struct CustomTabBar: View {
    @State private var selectedTab: Int = 0
    @Binding var authFlow: RootView.AuthFlow

    var body: some View {
        TabView(selection: $selectedTab) {
            FriendsAvailableScreen()
                .tabItem {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text("Friends")
                    }
                }
                .tag(0)

            EventsTabView()
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("Events")
                    }
                }
                .tag(1)
            NavigationStack {
                ProfileView(authFlow: $authFlow)
            }
                .tabItem {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                }
                .tag(2)
        }
        .accentColor(.orange) // Customize tab item selection color
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CustomTabBar(authFlow: .constant(.mainApp))
                .environmentObject(EventsViewModel())
        }
    }
}

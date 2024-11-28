//
//  ContentView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sharedData = SharedData()
    @Binding var showSignInView: Bool

    var body: some View {
        TabView {
            FriendsAvailableScreen()
                .tabItem {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text("Friends")
                    }
                }
                .tag(0)
                .environmentObject(sharedData)

            CurrentEventsView()
                .tabItem {
                    VStack {
                        Image(systemName: "calendar")
                        Text("Events")
                    }
                }
                .tag(1)
                .environmentObject(sharedData)

            ProfileView(showSignInView: $showSignInView)
                .tabItem {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                }
                .tag(2)
                .environmentObject(sharedData)
        }
        .accentColor(.orange) // Customize tab item selection color
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView(showSignInView: .constant(false))
            .environmentObject(SharedData())
    }
}

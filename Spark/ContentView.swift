//
//  ContentView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//
import SwiftUI
enum Tab {
    case profile, friendsAvailability, currentEvents // Updated case from addEvent to friendsAvailability
}
enum ProfileNavigation: Hashable {
    case child
}
enum EventNavigation: Hashable {
    case child
}
struct ContentView: View {
    @State private var selectedTab: Tab = .profile
    @State private var profileStack: [ProfileNavigation] = []
    @State private var eventStack: [EventNavigation] = []
    @StateObject private var sharedData = SharedData()
    @State private var tabSelected: tabTracker = .profile
    
    var body: some View {
        VStack {
            Spacer()
            switch selectedTab {
            case .profile:
                ProfileView()
                    .environmentObject(sharedData)
            case .friendsAvailability: // Updated case
                FriendsAvailabilityView() // Replaced AddEventView with FriendsAvailabilityView
                    .environmentObject(sharedData)
            case .currentEvents:
                CurrentEventsView()
                    .environmentObject(sharedData)
            }
            Spacer()
            CustomTabBar(tabSelected: $tabSelected, selectedTab: $selectedTab)
                .padding(.bottom, -30)
        }
    }
}
struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SharedData())
    }
}




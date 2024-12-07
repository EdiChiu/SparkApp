////
////  ContentView.swift
////  Spark
////
////  Created by Edison Chiu on 11/15/24.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var sharedData = SharedData()
//    @Binding var authFlow: RootView.AuthFlow
//
//    var body: some View {
//        TabView {
//            FriendsAvailableScreen()
//                .tabItem {
//                    VStack {
//                        Image(systemName: "person.2.fill")
//                        Text("Friends")
//                    }
//                }
//                .tag(0)
//                .environmentObject(sharedData)
//
//            CurrentEventsView()
//                .tabItem {
//                    VStack {
//                        Image(systemName: "calendar")
//                        Text("Events")
//                    }
//                }
//                .tag(1)
//                .environmentObject(sharedData)
//
//            ProfileView(authFlow: $authFlow)
//                .tabItem {
//                    VStack {
//                        Image(systemName: "person.crop.circle")
//                        Text("Profile")
//                    }
//                }
//                .tag(2)
//                .environmentObject(sharedData)
//        }
//        .accentColor(.orange) // Customize tab item selection color
//    }
//}
//
//struct ContentView_Preview: PreviewProvider {
//    static var previews: some View {
//        ContentView(authFlow: .constant(.mainApp))
//            .environmentObject(SharedData())
//    }
//}

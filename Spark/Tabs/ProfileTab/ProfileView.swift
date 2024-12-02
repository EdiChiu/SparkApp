//
//  ProfileView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI

struct ProfileView: View {
    @State private var Title = "Profile"
    @State private var isAvailable = true
    @StateObject private var viewModel = ProfileViewModel(userId: UUID().uuidString)
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack(spacing: 15) {

            // Title
            Text(Title)
                .font(.title)
                .fontWeight(.bold)
            
            // Availability Toggle
            Toggle("Available for Sponti", isOn: $isAvailable)
                .padding()
                .toggleStyle(SwitchToggleStyle(tint: .green))
            
            // Upcoming Events Section
            List {
                
                // Preferences or Settings
                Section(header: Text("Settings")) {
                    NavigationLink(destination: SettingsView(showSignInView: $showSignInView)) {
                        Label("Account", systemImage: "person")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "lock")
                    }
                    NavigationLink(destination: Text("Notifications")) {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                Section(header: Text("App Info")) {
                    NavigationLink(destination: Text("Help & Support")) {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                    NavigationLink(destination: Text("About Twine")) {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .padding(.top, 10)
        }
        .navigationTitle("Profile")
        .padding()
    }
}

// Date formatter for events
private let eventDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView(showSignInView: .constant(false))
        }
    }
}




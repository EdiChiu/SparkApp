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
    @StateObject private var viewModel = ProfileViewModel() // ViewModel instance
    
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
                Section(header: Text("Upcoming Events")) {
                    if viewModel.upcomingEvents.isEmpty {
                        Text("No events for the upcoming week.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.upcomingEvents, id: \.eventIdentifier) { event in
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                Text("\(event.startDate, formatter: eventDateFormatter) - \(event.endDate, formatter: eventDateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // Preferences or Settings
                Section(header: Text("Settings")) {
                    NavigationLink(destination: Text("Account Settings")) {
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
            ProfileView()
        }
    }
}



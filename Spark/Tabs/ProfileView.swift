//
//  ProfileView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI

struct ProfileView: View {
    @State private var userName = "Edison Chiu"
    @State private var statusMessage = "Hey there! I'm using Twine."
    @State private var isAvailable = true
    
    var body: some View {
        VStack(spacing: 15) {
            // Profile Picture
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
                .padding(.top, 30)
            
            // Username
            Text(userName)
                .font(.title)
                .fontWeight(.bold)
            
            // Status Message
            Text(statusMessage)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            // Availability Toggle
            Toggle("Available for Sponti", isOn: $isAvailable)
                .padding()
                .toggleStyle(SwitchToggleStyle(tint: .green))
            
            // Edit Profile Button
            Button(action: {
                // Action for editing profile goes here
            }) {
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
            }
            .padding(.bottom, 20)
            
            // Preferences or Settings
            List {
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}

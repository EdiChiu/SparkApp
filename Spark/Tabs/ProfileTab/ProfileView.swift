//
//  ProfileView.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var authFlow: RootView.AuthFlow

    var body: some View {
        ZStack(alignment: .top) {
            // Background Color
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 15) {
                // Title Section
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .foregroundColor(Color.primary)

                // User Details Section
                VStack(alignment: .leading, spacing: 10) {
                    DetailRow(label: "First Name", value: viewModel.firstName)
                    DetailRow(label: "Last Name", value: viewModel.lastName)
                    DetailRow(label: "Email", value: viewModel.email)
                    DetailRow(label: "Username", value: viewModel.userName)
                    // DND Toggle
                    Toggle("Do Not Disturb", isOn: $viewModel.dnd)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                        .padding(.vertical, 5)
                        .foregroundColor(Color.secondary)
                        .font(.headline)
                        .onChange(of: viewModel.dnd) { newValue in
                            Task {
                                try? await viewModel.updateDNDStatus(isDND: newValue)
                            }
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemBackground))
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)

                // Settings Section
                VStack(spacing: 10) {
                    NavigationLink(destination: SettingsView(authFlow: $authFlow)) {
                        SettingsRow(label: "Account", icon: "person")
                    }
                    NavigationLink(destination: PrivacyView()) {
                        SettingsRow(label: "Privacy", icon: "lock")
                    }
                    NavigationLink(destination: CurrentEventsView()) {
                        SettingsRow(label: "Calendar", icon: "calendar")
                    }
                }
                .padding()
            }
            .navigationBarHidden(true) // Hide default navigation bar
            .onAppear {
                fetchUserProfile()
            }
        }
    }
    
    private func fetchUserProfile() {
        Task {
            do {
                try await viewModel.fetchUserProfile()
            } catch {
                print("Error fetching user profile: \(error.localizedDescription)")
            }
        }
    }
}

// Custom Detail Row for User Info
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(Color.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(Color.primary)
        }
        .padding(.vertical, 5)
    }
}

// Custom Row for Settings Navigation Links
struct SettingsRow: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 30) // Fixed width for icons
            Text(label)
                .font(.headline)
                .foregroundColor(Color.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(authFlow: .constant(.mainApp))
        }
    }
}

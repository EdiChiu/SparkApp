////
////  ProfileView.swift
////  Spark
////
////  Created by Edison Chiu on 11/15/24.
////
//
//import SwiftUI
//import FirebaseFirestore
//
//struct ProfileView: View {
//    @StateObject private var viewModel = ProfileViewModel()
//    @Binding var authFlow: RootView.AuthFlow
//    @State private var isEditingUsername = false
//
//    var body: some View {
//        VStack(spacing: 15) {
//            
//            // User Info Section
//            VStack(alignment: .leading, spacing: 10) {
//                Text("First Name: \(viewModel.firstName)")
//                    .font(.headline)
//                Text("Last Name: \(viewModel.lastName)")
//                    .font(.headline)
//                Text("Email: \(viewModel.email)")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//            .padding()
//
//            // Username Section
//            HStack {
//                if isEditingUsername {
//                    TextField("Enter new username", text: $viewModel.userName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding(.trailing, 10)
//                } else {
//                    Text("Username: \(viewModel.userName)")
//                        .font(.headline)
//                }
//                Button(isEditingUsername ? "Save" : "Edit") {
//                    if isEditingUsername {
//                        saveUsername()
//                    }
//                    isEditingUsername.toggle()
//                }
//                .buttonStyle(BorderlessButtonStyle())
//            }
//            .padding()
//
//            // Availability Toggle ADD HERE
//            
//            // Upcoming Events Section
//            List {
//                Section(header: Text("Settings")) {
//                    NavigationLink(destination: SettingsView(authFlow: $authFlow)) {
//                        Label("Account", systemImage: "person")
//                    }
//                    NavigationLink(destination: Text("Privacy Settings")) {
//                        Label("Privacy", systemImage: "lock")
//                    }
//                    NavigationLink(destination: Text("Notifications")) {
//                        Label("Notifications", systemImage: "bell")
//                    }
//                    NavigationLink(destination: Text("Calendar")) {
//                        Label("Calendar", systemImage: "calendar")
//                    }
//                }
//            }
//            .listStyle(GroupedListStyle())
//            .padding(.top, 10)
//        }
//        .navigationTitle("Profile")
//        .padding()
//        .onAppear {
//            fetchUserProfile()
//        }
//    }
//    
//    private func fetchUserProfile() {
//        Task {
//            do {
//                try await viewModel.fetchUserProfile()
//            } catch {
//                print("Error fetching user profile: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    private func saveUsername() {
//        Task {
//            do {
//                try await viewModel.saveUsername()
//                print("Username successfully updated!")
//            } catch {
//                print("Error saving username: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//// Date formatter for events
//private let eventDateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .short
//    return formatter
//}()
//
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            ProfileView(authFlow: .constant(.mainApp))
//        }
//    }
//}
//
//
//

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var authFlow: RootView.AuthFlow
    @State private var isEditingUsername = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User Details Section
                VStack(alignment: .leading, spacing: 15) {
                    DetailRow(label: "First Name", value: viewModel.firstName)
                    DetailRow(label: "Last Name", value: viewModel.lastName)
                    DetailRow(label: "Email", value: viewModel.email)
                    
                    HStack {
                        Text("Username")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        if isEditingUsername {
                            TextField("Enter new username", text: $viewModel.userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(viewModel.userName)
                                .font(.body)
                        }
                        Button(action: {
                            if isEditingUsername {
                                saveUsername()
                            }
                            isEditingUsername.toggle()
                        }) {
                            Text(isEditingUsername ? "Save" : "Edit")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(isEditingUsername ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                )
                .padding(.horizontal)

                // Settings Section
                VStack(spacing: 10) {
                    NavigationLink(destination: SettingsView(authFlow: $authFlow)) {
                        SettingsRow(label: "Account", icon: "person")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        SettingsRow(label: "Privacy", icon: "lock")
                    }
                    NavigationLink(destination: Text("Notifications")) {
                        SettingsRow(label: "Notifications", icon: "bell")
                    }
                    NavigationLink(destination: Text("Calendar")) {
                        SettingsRow(label: "Calendar", icon: "calendar")
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Profile")
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            fetchUserProfile()
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

    private func saveUsername() {
        Task {
            do {
                try await viewModel.saveUsername()
                print("Username successfully updated!")
            } catch {
                print("Error saving username: \(error.localizedDescription)")
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
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
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
                .foregroundColor(.blue)
            Text(label)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
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

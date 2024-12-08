//
//  AddUserView.swift
//  Spark
//
//  Created by Edison Chiu on 12/3/24.
//

import SwiftUI
import FirebaseFirestore

struct AddUserView: View {
    @StateObject private var viewModel = AddUserViewModel()
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("Add Friends")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                // Search Bar
                VStack(spacing: 8) {
                    HStack {
                        TextField("Search by Username...", text: $searchText)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .textInputAutocapitalization(.never)

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: searchText) { _ in
                        viewModel.filterUsers(by: searchText)
                    }

                }

                // Filtered List of Users
                ScrollView {
                    LazyVStack(spacing: 15) {
                        if viewModel.filteredUsers.isEmpty {
                            Text("No users found.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(viewModel.filteredUsers, id: \.id) { user in
                                UserCard(user: user, action: {
                                    viewModel.addFriend(to: user.uid)
                                })
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(.systemGroupedBackground))
                .frame(maxHeight: .infinity)
            }
            .padding(.top)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchAllUsers()
            }
        }
    }
}

// MARK: - User Card
struct UserCard: View {
    let user: AppUser
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(user.userName)
                    .font(.headline)
                    .fontWeight(.bold)
                Text("\(user.firstName) \(user.lastName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: action) {
                Text("Add")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Preview
struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
            .environmentObject(AddUserViewModel()) // Ensure the environment object is provided
    }
}

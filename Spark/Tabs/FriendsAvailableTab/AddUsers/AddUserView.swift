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
    @State private var showPopup: Bool = false
    @State private var popupMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Friends")
                    .font(.largeTitle)
                    .fontWeight(.bold)

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

                ScrollView {
                    LazyVStack(spacing: 15) {
                        if viewModel.filteredUsers.isEmpty {
                            Text("No users found.")
                                .foregroundColor(.gray)
                                .padding(.top, 60)
                        } else {
                            ForEach(viewModel.filteredUsers, id: \.id) { user in
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
                                    if viewModel.currentUserFriends.contains(user.uid) {
                                        Text("Added")
                                            .font(.body)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    } else {
                                        Button(action: {
                                            viewModel.addFriend(to: user.uid)
                                            popupMessage = "\(user.userName) has been added to your friends list!"
                                            showPopup = true
                                        }) {
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
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(.systemGroupedBackground))
                .frame(maxHeight: .infinity)

                if showPopup {
                    VStack {
                        Text(popupMessage)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showPopup = false
                                    }
                                }
                            }
                    }
                    .padding(.bottom, 30)
                }
            }
            .padding(.top)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchAllUsers()
                viewModel.fetchCurrentUserFriends() // Fetch the user's current friends
            }
        }
    }
}
// MARK: - Preview
struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
            .environmentObject(AddUserViewModel()) // Ensure the environment object is provided
    }
}

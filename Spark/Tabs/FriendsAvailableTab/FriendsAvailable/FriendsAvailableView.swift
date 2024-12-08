//
//  FriendsAvailableView.swift
//  Spark
//
//  Created by 3 GO Participant on 11/18/24.
//

import SwiftUI

struct FriendsAvailableScreen: View {
    @StateObject private var viewModel = FriendsAvailableViewModel()
    @State private var selectedFriends: [String] = [] // Store selected friend UIDs

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header (Logo + Profile Icon)
                HStack {
                    Spacer()
                    Image("ExtendedLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(x: 15)
                    Spacer()
                    NavigationLink(destination: AddUserView()) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                Text("Friends Available")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 10)

                // Filter Buttons
                HStack(spacing: 15) {
                    NavigationLink(
                        destination: FilteredFriendsListView(
                            title: "Available Friends",
                            status: "Available",
                            viewModel: viewModel,
                            statusColor: .green,
                            selectedFriends: $selectedFriends
                        )
                    ) {
                        AvailabilityFilterButton(label: "Available", color: .green)
                    }
                    NavigationLink(
                        destination: FilteredFriendsListView(
                            title: "Free Soon Friends",
                            status: "Free Soon",
                            viewModel: viewModel,
                            statusColor: .yellow,
                            selectedFriends: $selectedFriends
                        )
                    ) {
                        AvailabilityFilterButton(label: "Free Soon", color: .yellow)
                    }
                    NavigationLink(
                        destination: FilteredFriendsListView(
                            title: "Busy Friends",
                            status: "Busy",
                            viewModel: viewModel,
                            statusColor: .red,
                            selectedFriends: $selectedFriends
                        )
                    ) {
                        AvailabilityFilterButton(label: "Busy", color: .red)
                    }
                }
                .padding()

                // Friend List
                if viewModel.isLoading {
                    ProgressView("Loading Friends...")
                        .padding(.top, 20)
                } else if viewModel.friends.isEmpty {
                    Text("No friends available.")
                        .padding(.top, 20)
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(viewModel.friends, id: \.uid) { friend in
                                SelectableFriendRow(
                                    name: friend.name,
                                    statusColor: colorForStatus(friend.status),
                                    isSelected: selectedFriends.contains(friend.uid),
                                    toggleSelection: {
                                        if let index = selectedFriends.firstIndex(of: friend.uid) {
                                            selectedFriends.remove(at: index) // Deselect
                                        } else {
                                            selectedFriends.append(friend.uid) // Select
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                // Create Event Button
                NavigationLink(destination: CreateEventScreen(selectedFriends: selectedFriends)
                                .environmentObject(viewModel)) {
                    HStack {
                        Text("Create Event")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "plus")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(25)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .opacity(selectedFriends.isEmpty ? 0.5 : 1.0) // Adjust opacity
                }
                .disabled(selectedFriends.isEmpty) // Disable if no friends selected
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .onAppear {
                viewModel.fetchFriends()
            }
        }
        .accentColor(Color.blue)
    }

    // Helper function to determine color based on friend status
    private func colorForStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "available": return .green
        case "free soon": return .yellow
        case "busy": return .red
        default: return .gray
        }
    }
}

struct SelectableFriendRow: View {
    var name: String
    var statusColor: Color
    var isSelected: Bool
    var toggleSelection: () -> Void

    var body: some View {
        HStack {
            // Selection indicator
            Circle()
                .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                .background(isSelected ? Circle().fill(Color.blue) : nil)
                .frame(width: 18, height: 18)
                .onTapGesture {
                    toggleSelection()
                }

            // Friend name and status
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            Circle()
                .fill(statusColor)
                .frame(width: 16, height: 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct FilteredFriendsListView: View {
    let title: String
    let status: String
    @ObservedObject var viewModel: FriendsAvailableViewModel
    let statusColor: Color
    @Binding var selectedFriends: [String]

    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(viewModel.filterFriends(by: status), id: \.name) { friend in
                        SelectableFriendRow(
                            name: friend.name,
                            statusColor: statusColor,
                            isSelected: selectedFriends.contains(friend.name),
                            toggleSelection: {
                                if let index = selectedFriends.firstIndex(of: friend.name) {
                                    selectedFriends.remove(at: index)
                                } else {
                                    selectedFriends.append(friend.name)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
}

// Availability Filter Button
struct AvailabilityFilterButton: View {
    var label: String
    var color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

// Friend Row
struct FriendRow: View {
    var name: String
    var statusColor: Color

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary) // Dynamically adjusts for readability
            Spacer()
            Circle()
                .fill(statusColor)
                .frame(width: 16, height: 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1) // Dynamic border color
        )
    }
}

struct FriendsAvailableScreen_Previews: PreviewProvider {
    static var previews: some View {
        FriendsAvailableScreen()
            .environment(\.colorScheme, .light) // Preview in Light mode
        FriendsAvailableScreen()
            .environment(\.colorScheme, .dark)  // Preview in Dark mode
    }
}

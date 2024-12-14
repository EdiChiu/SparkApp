//
//  FriendsAvailableView.swift
//  Spark
//
//  Created by 3 GO Participant on 11/18/24.
//

import SwiftUI
import EventKitUI

struct FriendsAvailableScreen: View {
    @StateObject private var viewModel = FriendsAvailableViewModel()
    @State private var searchText: String = ""
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var showEventEditor = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header (Logo + Profile Icon)
                HStack {
                    Spacer()
                    Image("ExtendedLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .offset(x: 15)
                        .padding()
                    Spacer()
                    NavigationLink(destination: AddUserView()) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black) // Fixed color
                    }
                }
                .padding()

                Text("Friends Available")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black) // Fixed color
                    .padding()
                    .offset(y: -60)

                // Filter Buttons
                HStack(spacing: 15) {
                    NavigationLink(
                        destination: FilteredFriendsListView(
                            title: "Available Friends",
                            status: "Available",
                            viewModel: viewModel,
                            statusColor: .green,
                            selectedFriends: $viewModel.selectedFriends
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
                            selectedFriends: $viewModel.selectedFriends
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
                            selectedFriends: $viewModel.selectedFriends
                        )
                    ) {
                        AvailabilityFilterButton(label: "Busy", color: .red)
                    }
                }
                .padding()
                .offset(y: -70)

                // Friend List
                if viewModel.isLoading {
                    ProgressView("Loading Friends...")
                        .padding(.top, 20)
                        .offset(y: -60)
                } else if viewModel.filteredFriends().isEmpty {
                    Text("No friends available.")
                        .padding(.top, 20)
                        .foregroundColor(.gray)
                        .offset(y: -60)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(viewModel.filteredFriends(), id: \.uid) { friend in
                                SelectableFriendRow(
                                    name: friend.name,
                                    statusColor: colorForStatus(friend.status),
                                    isSelected: viewModel.selectedFriends.contains(friend.uid),
                                    toggleSelection: {
                                        if let index = viewModel.selectedFriends.firstIndex(of: friend.uid) {
                                            viewModel.selectedFriends.remove(at: index) // Deselect
                                        } else {
                                            viewModel.selectedFriends.append(friend.uid) // Select
                                        }
                                    },
                                    onDelete: {
                                        viewModel.removeFriend(friend: friend)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .offset(y: -60)
                }

                // Create Event Button
                Button(action: {
                    viewModel.saveParticipantsUIDsToFirestore()
                    presentEventEditor()
                }) {
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
                    .opacity(viewModel.selectedFriends.isEmpty ? 0.5 : 1.0) // Adjust opacity
                }
                .disabled(viewModel.selectedFriends.isEmpty) // Disable if no friends selected
            }
            .background(Color.white.edgesIgnoringSafeArea(.all)) // Enforce white background
            .offset(y: -20)
            .onAppear {
                viewModel.fetchFriends()
            }
        }
        .accentColor(Color.blue)
    }

    private func presentEventEditor() {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = "New Event"
                    event.startDate = Date()
                    event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
                    event.calendar = eventStore.defaultCalendarForNewEvents

                    let eventEditVC = EKEventEditViewController()
                    eventEditVC.event = event
                    eventEditVC.eventStore = eventStore
                    eventEditVC.editViewDelegate = eventsViewModel

                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                        rootVC.present(eventEditVC, animated: true) {
                            // Reset form and navigate back after the event editor is dismissed
                            if let savedEvent = eventEditVC.event {
                                handleEventSaved(savedEvent)
                            }
                        }
                    }
                }
            } else if let error = error {
                print("Error requesting calendar access: \(error.localizedDescription)")
            }
        }
    }

    private func handleEventSaved(_ event: EKEvent) {
        // Reset the selected friends
        viewModel.resetSelectedFriends()

        // Navigate back to the previous view
        presentationMode.wrappedValue.dismiss()
    }

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
    var onDelete: () -> Void

    @State private var offset: CGFloat = 0.0
    @GestureState private var isDragging: Bool = false

    var body: some View {
        ZStack {
            // Background layer with delete button
            HStack {
                Spacer()
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .background(Color.white) // Ensures consistent light background
            .cornerRadius(15)

            // Foreground layer with friend row content
            HStack {
                Circle()
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                    .background(isSelected ? Circle().fill(Color.blue) : nil)
                    .frame(width: 18, height: 18)
                    .onTapGesture {
                        toggleSelection()
                    }

                Text(name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black) // Fixed color for text

                Spacer()

                Circle()
                    .fill(statusColor)
                    .frame(width: 16, height: 16)
            }
            .padding()
            .background(Color.white) // Fixed background color
            .cornerRadius(15)
            .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .updating($isDragging, body: { (value, state, _) in
                        state = true
                    })
                    .onChanged { value in
                        // Allow swiping only to the left
                        if value.translation.width < 0 {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        // Show the delete button if swiped past a threshold, otherwise reset
                        if value.translation.width < -100 {
                            offset = -100
                        } else {
                            offset = 0
                        }
                    }
            )
        }
        .animation(.easeInOut, value: offset)
    }
}

struct FilteredFriendsListView: View {
    let title: String
    let status: String
    @ObservedObject var viewModel: FriendsAvailableViewModel
    let statusColor: Color
    @Binding var selectedFriends: [String]

    var body: some View {
        ZStack {
            // Background color for the entire screen
            Color.white
                .edgesIgnoringSafeArea(.all) // Ensure the background covers the full screen

            VStack(spacing: 15) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top)

                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.filterFriends(by: status), id: \.uid) { friend in
                            SelectableFriendRow(
                                name: friend.name,
                                statusColor: statusColor,
                                isSelected: selectedFriends.contains(friend.uid),
                                toggleSelection: {
                                    if let index = selectedFriends.firstIndex(of: friend.uid) {
                                        selectedFriends.remove(at: index)
                                    } else {
                                        selectedFriends.append(friend.uid)
                                    }
                                },
                                onDelete: {
                                    viewModel.removeFriend(friend: friend)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

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
        .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

struct FriendRow: View {
    var name: String
    var statusColor: Color

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black) // Fixed color for text
            Spacer()
            Circle()
                .fill(statusColor)
                .frame(width: 16, height: 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Fixed border color
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

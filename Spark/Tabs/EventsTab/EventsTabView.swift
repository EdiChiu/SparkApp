//
//  EventsTabView.swift
//  Spark
//
//  Created by Edison Chiu on 12/10/24.
//

import SwiftUI
import FirebaseAuth

struct EventsTabView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel

    var body: some View {
        NavigationView {
            VStack {
                if eventsViewModel.userEvents.isEmpty && eventsViewModel.pendingEvents.isEmpty {
                    Text("No upcoming events.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            // Show userEvents
                            ForEach(eventsViewModel.userEvents, id: \.id) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            // Show pendingEvents with Accept/Deny buttons
                            ForEach(eventsViewModel.pendingEvents, id: \.id) { event in
                                EventCard(event: event)
                                    .environmentObject(eventsViewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                eventsViewModel.fetchEvents()
            }
            .navigationTitle("My Events")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EventCard: View {
    let event: UserEvent
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var hasResponded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title and "Pending" badge
            HStack {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                // Show "Pending" button if there are pending participants
                if !event.pendingParticipants.isEmpty {
                    Text("Pending")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(5)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundColor(.yellow)
                        .cornerRadius(8)
                }
            }

            // Location and duration
            if !event.location.isEmpty {
                Text("Location: \(event.location)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text("Created: \(event.creationTime.formattedDate())")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Accept/Deny buttons for pending participants
            if event.pendingParticipants.contains(Auth.auth().currentUser?.uid ?? ""), !hasResponded {
                HStack {
                    Button(action: {
                        eventsViewModel.acceptEvent(event: event)
                        hasResponded = true
                    }) {
                        Text("Accept")
                            .font(.caption)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        eventsViewModel.denyEvent(event: event)
                        hasResponded = true
                    }) {
                        Text("Deny")
                            .font(.caption)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Full-width card
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal) // Add spacing between cards and screen edges
    }
}

struct EventDetailView: View {
    let event: UserEvent
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var creatorName: String = "Loading..."
    @State private var acceptedNames: [String] = []
    @State private var deniedNames: [String] = []
    @State private var pendingNames: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event title
                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Event location
                if !event.location.isEmpty {
                    Text("Location: \(event.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Event Creation Time
                Text("Created: \(event.creationTime.formattedDate())")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Event duration
                let hours = event.duration / 3600
                let minutes = (event.duration % 3600) / 60
                Text("Duration: \(hours) hrs \(minutes) mins")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Event description
                if !event.description.isEmpty {
                    Text("Description: \(event.description)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider()

                // Creator's name
                Text("Creator: \(creatorName)")
                    .font(.headline)

                Divider()

                // Participants grouped by status
                if !acceptedNames.isEmpty {
                    Text("Accepted Participants:")
                        .font(.headline)
                    ForEach(acceptedNames, id: \.self) { name in
                        Text(name)
                            .font(.body)
                            .foregroundColor(.green)
                    }
                }

                if !pendingNames.isEmpty {
                    Text("Pending Participants:")
                        .font(.headline)
                    ForEach(pendingNames, id: \.self) { name in
                        Text(name)
                            .font(.body)
                            .foregroundColor(.yellow)
                    }
                }

                if !deniedNames.isEmpty {
                    Text("Denied Participants:")
                        .font(.headline)
                    ForEach(deniedNames, id: \.self) { name in
                        Text(name)
                            .font(.body)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Fetch creator's full name
            eventsViewModel.fetchUserFullName(uid: event.creatorUID) { name in
                if let name = name {
                    creatorName = name
                } else {
                    creatorName = "Unknown"
                }
            }

            // Fetch participants grouped by status
            eventsViewModel.fetchParticipantsByStatus(
                acceptedUIDs: event.acceptedParticipants,
                deniedUIDs: event.deniedParticipants,
                pendingUIDs: event.pendingParticipants
            ) { accepted, denied, pending in
                acceptedNames = accepted
                deniedNames = denied
                pendingNames = pending
            }
        }
    }
}

// MARK: - Date Extension
extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

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
                if eventsViewModel.userEvents.isEmpty {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title
            Text(event.title)
                .font(.headline)
                .fontWeight(.bold)

            // Location
            if !event.location.isEmpty {
                Text("Location: \(event.location)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Start and End Time
            Text("Start: \(event.startTime.formattedDate())")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("End: \(event.endTime.formattedDate())")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Creation Time
            Text("Created: \(event.creationTime.formattedDate())")
                .font(.subheadline)
                .foregroundColor(.gray)
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
    @State private var participantsNames: [String] = []

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

                // Start and End Time
                Text("Start: \(event.startTime.formattedDate())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("End: \(event.endTime.formattedDate())")
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

                // Participants
                if !participantsNames.isEmpty {
                    Text("Participants:")
                        .font(.headline)
                    ForEach(participantsNames, id: \.self) { name in
                        Text(name)
                            .font(.body)
                            .foregroundColor(.primary)
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
                DispatchQueue.main.async {
                    creatorName = name ?? "Unknown"
                    print("Fetched creator name: \(creatorName)")
                }
            }

            // Fetch participant names
            print("Fetching participants for UIDs: \(event.participantsUIDs)")
            eventsViewModel.fetchParticipantsNames(uids: event.participantsUIDs) { names in
                DispatchQueue.main.async {
                    participantsNames = names.values.sorted()
                    print("Fetched participants names: \(participantsNames)")
                }
            }
        }    }
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

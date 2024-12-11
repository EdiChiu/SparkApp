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
                            ForEach(eventsViewModel.userEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            // Show pendingEvents with Accept/Deny buttons
                            ForEach(eventsViewModel.pendingEvents) { event in
                                EventCard(event: event, isPending: true)
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
    var isPending: Bool = false
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var hasResponded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                if !isPending {
                    if event.status == .pending {
                        Text("Pending")
                            .font(.caption)
                            .padding(5)
                            .background(Color.yellow.opacity(0.2))
                            .foregroundColor(.yellow)
                            .cornerRadius(8)
                    } else if event.status == .accepted {
                        Text("Accepted")
                            .font(.caption)
                            .padding(5)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }
                }
            }

            Text("Location: \(event.location)")
                .font(.subheadline)
                .foregroundColor(.gray)

            let hours = event.duration / 3600
            let minutes = (event.duration % 3600) / 60
            Text("Duration: \(hours) hrs \(minutes) mins")
                .font(.subheadline)
                .foregroundColor(.gray)

            if isPending && !hasResponded {
                HStack {
                    Button(action: {
                        eventsViewModel.respondToEvent(event: event, accepted: true)
                        hasResponded = true
                    }) {
                        Text("Accept")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        eventsViewModel.respondToEvent(event: event, accepted: false)
                        hasResponded = true
                    }) {
                        Text("Deny")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
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

                // Participants
                Text("Participants:")
                    .font(.headline)
                
                ForEach(participantsNames, id: \.self) { name in
                    Text(name)
                        .font(.body)
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

            // Fetch participants' names
            eventsViewModel.fetchParticipantsNames(uids: event.participantsUIDs) { names in
                participantsNames = names.values.sorted()
            }
        }
    }
}

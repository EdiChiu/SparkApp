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
    @Environment(\.colorScheme) var colorScheme

    init() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationView {
            VStack {
                if eventsViewModel.userEvents.isEmpty {
                    Text("No events created yet.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            // Show all created events
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
                eventsViewModel.fetchEvents() // Fetch all events on view appearance
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
            // Event Title
            Text(event.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)

            // Event Location
            if !event.location.isEmpty {
                Text("Location: \(event.location)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // Event Creation Time
            Text("Created: \(event.creationTime.formattedDate())")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct EventDetailView: View {
    let event: UserEvent
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var creatorName: String = "Loading..."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Title
                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Event Location
                if !event.location.isEmpty {
                    Text("Location: \(event.location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Event Creation Time
                Text("Created: \(event.creationTime.formattedDate())")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Event Attendees
                if !event.description.isEmpty {
                    Text("\(event.description)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider()

                // Creator's Name
                Text("Creator: \(creatorName)")
                    .font(.headline)
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            eventsViewModel.fetchUserFullName(uid: event.creatorUID) { name in
                creatorName = name ?? "Unknown"
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

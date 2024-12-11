//
//  EventsTabView.swift
//  Spark
//
//  Created by Edison Chiu on 12/10/24.
//

import SwiftUI

struct EventsTabView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationView { // Wrap the whole view in NavigationView
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("My Events").tag(0)
                    Text("Pending Invitations").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(.systemGray6))

                Group {
                    if selectedTab == 0 {
                        userEventsView
                    } else {
                        pendingEventsView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                eventsViewModel.fetchEvents()
            }
        }
    }

    // MARK: - My Events View
    private var userEventsView: some View {
        VStack {
            if eventsViewModel.userEvents.isEmpty {
                Text("No upcoming events.")
                    .foregroundColor(.gray)
                    .padding(.top, 50)
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(eventsViewModel.userEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventCard(event: event)
                            }
                            .buttonStyle(PlainButtonStyle()) // Avoids navigation animation interfering with EventCard styling
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Pending Invitations View
    private var pendingEventsView: some View {
        VStack {
            if eventsViewModel.pendingEvents.isEmpty {
                Text("No pending invitations.")
                    .foregroundColor(.gray)
                    .padding(.top, 50)
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(eventsViewModel.pendingEvents) { event in
                            HStack {
                                EventCard(event: event)
                                Spacer()
                                VStack {
                                    Button(action: {
                                        eventsViewModel.acceptEvent(event: event)
                                    }) {
                                        Text("Accept")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    }
                                    Button(action: {
                                        eventsViewModel.denyEvent(event: event)
                                    }) {
                                        Text("Decline")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.red)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Event Card View
struct EventCard: View {
    let event: UserEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(event.title)
                .font(.headline)
                .fontWeight(.bold)

            if !event.location.isEmpty {
                Text("Location: \(event.location)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            let hours = event.duration / 3600
            let minutes = (event.duration % 3600) / 60
            Text("Duration: \(hours) hrs \(minutes) mins")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Makes the card rectangular
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct EventDetailView: View {
    let event: UserEvent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 15) {
                    // Event Title
                    Text(event.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)

                    // Location
                    if !event.location.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Location")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(event.location)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Duration
                    let hours = event.duration / 3600
                    let minutes = (event.duration % 3600) / 60
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Duration")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("\(hours) hrs \(minutes) mins")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Description
                    if !event.description.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(event.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(5)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

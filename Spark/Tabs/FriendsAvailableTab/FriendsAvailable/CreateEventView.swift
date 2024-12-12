//
//  CreateEventView.swift
//  Spark
//
//  Created by Edison Chiu on 12/7/24.
//

import SwiftUI
import FirebaseAuth

struct CreateEventScreen: View {
    @State private var eventName: String = ""
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    var selectedFriends: [String] // Array of selected friend UIDs
    @EnvironmentObject var viewModel: FriendsAvailableViewModel
    @EnvironmentObject var eventsViewModel: EventsViewModel

    // Computed property to check if the form is valid
    private var isFormComplete: Bool {
        !eventName.isEmpty &&
        !location.isEmpty &&
        !description.isEmpty &&
        (durationHours > 0 || durationMinutes > 0) &&
        !selectedFriends.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Create New Event")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .padding(.horizontal, 20)

                // Event Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Name")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter event name", text: $eventName)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .textInputAutocapitalization(.words)
                }

                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter location", text: $location)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .textInputAutocapitalization(.words)
                }

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter description", text: $description, axis: .vertical)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .lineLimit(4)
                }

                // Duration Pickers
                VStack(spacing: 10) {
                    Text("Duration")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack(spacing: 30) {
                        VStack(spacing: 5) {
                            Text("Hours")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Picker("Hours", selection: $durationHours) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .frame(width: 60, height: 100)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                        }

                        VStack(spacing: 5) {
                            Text("Minutes")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Picker("Minutes", selection: $durationMinutes) {
                                ForEach(0..<60, id: \.self) { minute in
                                    Text("\(minute)").tag(minute)
                                }
                            }
                            .frame(width: 60, height: 100)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    .padding(.horizontal, 10)
                }

                // Selected Friends List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Selected Friends")
                        .font(.headline)
                        .foregroundColor(.gray)

                    if selectedFriends.isEmpty {
                        Text("No friends selected.")
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(12)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(selectedFriends, id: \.self) { friendUID in
                                    if let friend = viewModel.friends.first(where: { $0.uid == friendUID }) {
                                        HStack {
                                            Text(friend.name)
                                                .font(.body)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.orange.opacity(0.15))
                                        .cornerRadius(12)
                                    } else {
                                        HStack {
                                            Text(friendUID)
                                                .font(.body)
                                                .italic()
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                }

                // Submit Button
                Button(action: {
                    createEvent()
                }) {
                    Text("Create Event")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormComplete ? Color.orange : Color.gray.opacity(0.4))
                        .cornerRadius(12)
                        .shadow(radius: isFormComplete ? 4 : 0)
                }
                .disabled(!isFormComplete)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 80)
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    @Environment(\.presentationMode) var presentationMode

    private func createEvent() {
        let duration = (durationHours * 3600) + (durationMinutes * 60)

        // Initialize pendingParticipants to include all selected friends
        let currentUserUID = Auth.auth().currentUser?.uid ?? ""

        let newEvent = UserEvent(
            id: UUID().uuidString,
            title: eventName,
            location: location,
            description: description,
            duration: duration,
            creatorUID: currentUserUID,
            creationTime: Date(),
            participantsUIDs: selectedFriends,
            acceptedParticipants: [],
            deniedParticipants: [],
            pendingParticipants: selectedFriends
        )

        eventsViewModel.addEvent(event: newEvent)
        resetForm()
        viewModel.resetSelectedFriends() // Reset the friends selection
        presentationMode.wrappedValue.dismiss() // Navigate back to FriendsAvailableView
    }
    
    private func resetForm() {
        eventName = ""
        location = ""
        description = ""
        durationHours = 0
        durationMinutes = 0
    }
}


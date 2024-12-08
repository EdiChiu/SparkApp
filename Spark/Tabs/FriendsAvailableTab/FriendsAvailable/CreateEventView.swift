//
//  CreateEventView.swift
//  Spark
//
//  Created by Edison Chiu on 12/7/24.
//

import SwiftUI

struct CreateEventScreen: View {
    @EnvironmentObject var viewModel: FriendsAvailableViewModel
    @State private var eventName: String = ""
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0
    var selectedFriends: [String] // Array of selected friend UIDs

    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Event")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .padding(10)

            // Event Name
            TextField("Event Name", text: $eventName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .textInputAutocapitalization(.words)
            
            // Location
            TextField("Location", text: $location)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .textInputAutocapitalization(.words)

            // Description
            TextField("Description", text: $description, axis: .vertical)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .lineLimit(4)

            // Duration Pickers
            VStack(alignment: .leading, spacing: 10) {
                Text("Duration:")
                    .font(.headline)

                HStack(spacing: 20) {
                    Picker("Hours", selection: $durationHours) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour) \(hour == 1 ? "Hour" : "Hours")")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 100)
                    .clipped()

                    Picker("Minutes", selection: $durationMinutes) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text("\(minute) \(minute == 1 ? "Minute" : "Minutes")")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 100)
                    .clipped()
                }
            }

            // Selected Friends List
            VStack(alignment: .leading, spacing: 10) {
                Text("Selected Friends:")
                    .font(.headline)

                if selectedFriends.isEmpty {
                    Text("No friends selected.")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(selectedFriends, id: \.self) { friendUID in
                                if let friend = viewModel.friends.first(where: { $0.uid == friendUID }) {
                                    Text(friend.name) // Show concatenated name
                                        .font(.body)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                } else {
                                    Text(friendUID) // Fallback to UID if name not found
                                        .font(.body)
                                        .italic()
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 100) // Limit height
                }
            }

            // Submit Button
            Button(action: {
                let duration = (durationHours * 3600) + (durationMinutes * 60)
                print("Event Created: \(eventName), Duration: \(duration) seconds, \(location), \(description)")
                print("Invited Friends: \(selectedFriends)")
            }) {
                Text("Create Event")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(15)
            }
            .padding(.bottom)  // Add padding to avoid overlap with the tab bar

            Spacer() // Push content to the top
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))  // Ensure the background is adaptive
        .navigationBarBackButtonHidden(false) // Ensure the back button is shown
    }
}

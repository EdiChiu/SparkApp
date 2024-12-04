//
//  FriendsAvailableView.swift
//  Spark
//
//  Created by 3 GO Participant on 11/18/24.
//

import SwiftUI

struct FriendsAvailableScreen: View {
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
                //.background(Color.white) // Keeps the header white for consistency

                Text("Friends Available")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary) // Adaptable text color
                    .padding(.top, 10)

                // Filter Buttons
                HStack(spacing: 15) {
                    NavigationLink(destination: FilteredFriendsListView(title: "Available Friends", statusColor: .green)) {
                        AvailabilityFilterButton(label: "Available", color: .green)
                    }
                    NavigationLink(destination: FilteredFriendsListView(title: "Free Soon Friends", statusColor: .yellow)) {
                        AvailabilityFilterButton(label: "Free Soon", color: .yellow)
                    }
                    NavigationLink(destination: FilteredFriendsListView(title: "Busy Friends", statusColor: .red)) {
                        AvailabilityFilterButton(label: "Busy", color: .red)
                    }
                }
                .padding()

                // Friend List
                ScrollView {
                    VStack(spacing: 15) {
                        FriendRow(name: "Edison Chiu", statusColor: .green)
                        FriendRow(name: "Diego Lagunas", statusColor: .green)
                        FriendRow(name: "Frank Blackman Jr.", statusColor: .green)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Create Event Button (not overlapping with Tab Bar)
                NavigationLink(destination: CreateEventScreen()) {
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
                }
                .padding(.bottom, 20) // Adjusted bottom padding to ensure no overlap with Tab Bar

            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all)) // Automatically adjusts to background color
        }
        .accentColor(Color.blue)
    }
}

struct FilteredFriendsListView: View {
    let title: String
    let statusColor: Color

    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            ScrollView {
                VStack(spacing: 15) {
                    FriendRow(name: "Frank Blackman Jr.", statusColor: statusColor)
                    FriendRow(name: "Diego Lagunas", statusColor: statusColor)
                    FriendRow(name: "Edison Chiu", statusColor: statusColor)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(title) // Dynamic title based on the availability
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground)) // Ensure background adapts
    }
}

struct CreateEventScreen: View {
    @State private var eventName: String = ""
    @State private var eventDate = Date()
    @State private var location: String = ""
    @State private var description: String = ""

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

            // Event Date
            VStack(alignment: .leading) {
                Text("Event Date:")
                    .font(.headline)
                DatePicker("Select Date", selection: $eventDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
            }

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

            // Submit Button
            Button(action: {
                // Handle event creation
                print("Event Created: \(eventName), \(eventDate), \(location), \(description)")
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
